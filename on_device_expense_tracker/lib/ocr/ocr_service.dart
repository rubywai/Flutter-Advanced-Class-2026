import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'ocr_result.dart';

class OcrService {
  OcrService({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  Future<OcrResult> recognizeFromFilePath(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final recognizedText = await _recognizer.processImage(inputImage);
    return OcrResult(fullText: recognizedText.text.trim());
  }

  Future<void> dispose() => _recognizer.close();
}

