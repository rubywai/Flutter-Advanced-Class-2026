# On-Device Expense Tracker

This project is a sample expense tracker application that leverages on-device Large Language Models (LLMs) for features like expense categorization and insights.

## Features

* **Expense Tracking**: Manually log your daily expenses.
* **On-Device LLM**: Utilizes a local Gemma model for intelligent expense categorization and analysis.
* **Data Visualization**: View your spending patterns through interactive charts.

## Setup

### Prerequisites

* Flutter SDK installed
* Dart SDK installed

### Running the Application

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd on_device_expense_tracker
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Gemma Model**:
   * The application uses a Gemma model hosted on Hugging Face. Ensure you have an active internet connection during the first run to download the model.
   * You can configure the model URL in `lib/llm/gemma_config.dart`.

4. **Run the app**:
   ```bash
   flutter run
   ```

## Gemma Configuration

The Gemma model configuration can be found in `lib/llm/gemma_config.dart`. You can modify the `modelUrl` to point to a different compatible Gemma model if needed.

```dart
class GemmaConfig {
  static const ModelType modelType = ModelType.gemmaIt;

  // TODO: Replace with your server-hosted model URL (.task for mobile).
  static const String modelUrl =
      'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm';

  static const int maxTokens = 2048;

  static String get modelFileName => Uri.parse(modelUrl).pathSegments.last;
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
