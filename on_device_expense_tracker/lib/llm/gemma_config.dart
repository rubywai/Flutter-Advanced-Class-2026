import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaConfig {
  static const ModelType modelType = ModelType.gemmaIt;

  // TODO: Replace with your server-hosted model URL (.task for mobile).
  static const String modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';

  static const int maxTokens = 2048;

  static String get modelFileName => Uri.parse(modelUrl).pathSegments.last;
}
