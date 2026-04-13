// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:on_device_expense_tracker/main.dart';

void main() {
  testWidgets('Recipe OCR page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Receipt OCR'), findsOneWidget);
    expect(find.text('Pick screenshot'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Extracted text'), findsOneWidget);
  });
}
