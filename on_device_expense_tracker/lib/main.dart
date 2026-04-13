import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'recipe_scan/recipe_scan_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterGemma.initialize(
    huggingFaceToken: const String.fromEnvironment('HUGGINGFACE_TOKEN'),
    maxDownloadRetries: 10,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    return MaterialApp(
      title: 'Receipt OCR',
      theme: ThemeData(colorScheme: colorScheme, useMaterial3: true),
      home: const RecipeScanPage(),
    );
  }
}
