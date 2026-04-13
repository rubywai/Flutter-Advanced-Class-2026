import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../llm/gemma_service.dart';
import '../ocr/ocr_service.dart';

class RecipeScanPage extends StatefulWidget {
  const RecipeScanPage({super.key});

  @override
  State<RecipeScanPage> createState() => _RecipeScanPageState();
}

class _RecipeScanPageState extends State<RecipeScanPage> {
  final _imagePicker = ImagePicker();
  final _ocrService = OcrService();
  final _gemmaService = GemmaService();

  XFile? _image;
  String _recognizedText = '';
  String _jsonText = '';
  bool _isBusy = false;
  int? _downloadProgress;
  ExtractionSchema _schema = ExtractionSchema.auto;

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _pickAndRecognize(ImageSource source) async {
    setState(() => _isBusy = true);
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (!mounted) return;
      if (image == null) {
        setState(() => _isBusy = false);
        return;
      }

      setState(() {
        _image = image;
        _recognizedText = '';
      });

      final result = await _ocrService.recognizeFromFilePath(image.path);
      if (!mounted) return;
      setState(() => _recognizedText = result.fullText);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OCR failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _copyToClipboard() async {
    if (_recognizedText.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _recognizedText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isBusy = true;
      _downloadProgress = 0;
    });
    try {
      await _gemmaService.ensureModelInstalled(
        onProgress: (p) {
          if (!mounted) return;
          setState(() => _downloadProgress = p);
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model installed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Model download failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _downloadProgress = null;
        });
      }
    }
  }

  Future<void> _convertToJson() async {
    final text = _recognizedText.trim();
    if (text.isEmpty) return;

    setState(() {
      _isBusy = true;
      _jsonText = '';
    });
    try {
      final jsonText = await _gemmaService.extractJson(
        text,
        schema: _schema,
      );
      if (!mounted) return;
      setState(() => _jsonText = jsonText);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Convert failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _copyJsonToClipboard() async {
    if (_jsonText.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _jsonText));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied to clipboard')),
    );
  }

  void _clear() {
    setState(() {
      _image = null;
      _recognizedText = '';
      _jsonText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt OCR')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed:
                        _isBusy ? null : () => _pickAndRecognize(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick screenshot'),
                  ),
                  FilledButton.icon(
                    onPressed:
                        _isBusy ? null : () => _pickAndRecognize(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take photo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _downloadModel,
                    icon: const Icon(Icons.download),
                    label: Text(
                      _downloadProgress == null
                          ? 'Download model'
                          : 'Downloading ${_downloadProgress!}%',
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _isBusy || _recognizedText.trim().isEmpty
                        ? null
                        : _convertToJson,
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('Convert to JSON'),
                  ),
                  SegmentedButton<ExtractionSchema>(
                    segments: const [
                      ButtonSegment(
                        value: ExtractionSchema.auto,
                        label: Text('Auto'),
                        icon: Icon(Icons.auto_awesome),
                      ),
                      ButtonSegment(
                        value: ExtractionSchema.receipt,
                        label: Text('Receipt'),
                        icon: Icon(Icons.receipt),
                      ),
                      ButtonSegment(
                        value: ExtractionSchema.invoice,
                        label: Text('Invoice'),
                        icon: Icon(Icons.receipt_long),
                      ),
                    ],
                    selected: {_schema},
                    onSelectionChanged: _isBusy
                        ? null
                        : (selection) {
                            setState(() => _schema = selection.first);
                          },
                  ),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy text'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _copyJsonToClipboard,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy JSON'),
                  ),
                  TextButton.icon(
                    onPressed: _isBusy ? null : _clear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_image != null) ...[
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.file(
                              File(_image!.path),
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Text(
                              'Extracted text',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            if (_isBusy)
                              const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  _recognizedText.isEmpty
                                      ? 'Pick an image to run OCR.'
                                      : _recognizedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'JSON output',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 160,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SingleChildScrollView(
                                child: SelectableText(
                                  _jsonText.isEmpty
                                      ? 'Tap “Convert to JSON” after OCR.'
                                      : _jsonText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
