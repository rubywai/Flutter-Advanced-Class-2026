import 'dart:convert';

import 'package:flutter_gemma/flutter_gemma.dart';

import 'gemma_config.dart';

enum ExtractionSchema { auto, receipt, invoice }

class GemmaService {
  Future<void> ensureModelInstalled({
    required void Function(int progress0to100) onProgress,
  }) async {
    onProgress(0);
    await FlutterGemma.installModel(modelType: GemmaConfig.modelType)
        .fromNetwork(GemmaConfig.modelUrl)
        .withProgress(onProgress)
        .install();
    onProgress(100);
  }

  Future<String> extractJson(
    String ocrText, {
    ExtractionSchema schema = ExtractionSchema.auto,
  }) async {
    await ensureModelInstalled(onProgress: (_) {});

    final selectedSchema = schema == ExtractionSchema.auto
        ? _detectSchema(ocrText)
        : schema;

    final model = await FlutterGemma.getActiveModel(
      maxTokens: GemmaConfig.maxTokens,
    );
    try {
      final chat = await model.createChat(
        systemInstruction: _systemInstruction,
      );
      await chat.addQueryChunk(
        Message.text(
          text: _prompt(ocrText, schema: selectedSchema),
          isUser: true,
        ),
      );
      final response = await chat.generateChatResponse();
      final responseText = switch (response) {
        TextResponse(:final token) => token,
        FunctionCallResponse() || ParallelFunctionCallResponse() =>
          jsonEncode({
            'error': 'Model returned a function call, expected JSON text',
          }),
        ThinkingResponse(:final content) => content,
      };
      return _extractJson(responseText);
    } finally {
      await model.close();
    }
  }

  static const String _systemInstruction =
      'You extract structured data from OCR text into strictly valid JSON. '
      'Return JSON only (no markdown, no backticks, no commentary).';

  static ExtractionSchema _detectSchema(String text) {
    final lower = text.toLowerCase();
    final invoiceSignals = [
      'invoice',
      'invoice#',
      'balance due',
      'sub total',
      'subtotal',
      'tax rate',
      'bill to',
      'ship to',
      'terms',
      'due date',
    ];
    if (invoiceSignals.any(lower.contains)) return ExtractionSchema.invoice;
    return ExtractionSchema.receipt;
  }

  static String _prompt(
    String ocrText, {
    required ExtractionSchema schema,
  }) {
    if (schema == ExtractionSchema.invoice) {
      return _invoicePrompt(ocrText);
    }
    return _receiptPrompt(ocrText);
  }

  static String _receiptPrompt(String ocrText) {
    const schema = '''
{
  "document_type": "receipt",
  "merchant": {
    "name": string|null,
    "address_lines": [string],
    "phone": string|null
  },
  "transaction_date": "YYYY-MM-DD"|null,
  "transaction_time": "HH:MM"|null,
  "items": [
    {
      "name": string,
      "quantity": number|null,
      "unit_price": number|null,
      "total_price": number|null
    }
  ],
  "sub_total": number|null,
  "tax": number|null,
  "tip": number|null,
  "total": number|null,
  "currency": string|null,
  "payment_method": string|null,
  "notes": [string]
}
''';

    return '''
Extract a receipt from this OCR text and output JSON matching this schema exactly.
Rules:
- JSON only (no markdown).
- Dates must be converted to YYYY-MM-DD when possible, else null.
- Money fields must be numbers (no currency symbols, no commas). If unknown, null.
- If the receipt doesn't list items, return an empty "items" array.
- "currency" should be a 3-letter code if you can infer (e.g., USD), else null.

Schema:
$schema

OCR text:
${ocrText.trim()}
''';
  }

  static String _invoicePrompt(String ocrText) {
    const schema = '''
{
  "document_type": "invoice",
  "vendor": {
    "name": string|null,
    "address_lines": [string],
    "city": string|null,
    "state": string|null,
    "postal_code": string|null,
    "country": string|null
  },
  "invoice_number": string|null,
  "invoice_date": "YYYY-MM-DD"|null,
  "terms": string|null,
  "due_date": "YYYY-MM-DD"|null,
  "bill_to": {
    "name": string|null,
    "address_lines": [string],
    "city": string|null,
    "state": string|null,
    "postal_code": string|null,
    "country": string|null
  },
  "ship_to": {
    "name": string|null,
    "address_lines": [string],
    "city": string|null,
    "state": string|null,
    "postal_code": string|null,
    "country": string|null
  },
  "line_items": [
    {
      "name": string,
      "description": string|null,
      "quantity": number|null,
      "unit_price": number|null,
      "amount": number|null
    }
  ],
  "sub_total": number|null,
  "tax_rate_percent": number|null,
  "tax_amount": number|null,
  "total": number|null,
  "balance_due": number|null,
  "currency": string|null
}
''';

    return '''
Extract an invoice from this OCR text and output JSON matching this schema exactly.
Rules:
- JSON only (no markdown).
- Dates must be converted to YYYY-MM-DD when possible, else null.
- Money/amount fields must be numbers (no currency symbols, no commas). If unknown, null.
- "currency" should be a 3-letter code if you can infer (e.g., USD), else null.
- Keep "address_lines" as an array of lines; do not merge.

Schema:
$schema

OCR text:
${ocrText.trim()}
''';
  }

  static String _extractJson(String text) {
    final trimmed = text.trim();
    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return trimmed;
    final candidate = trimmed.substring(start, end + 1);

    try {
      final decoded = jsonDecode(candidate);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return candidate;
    }
  }
}
