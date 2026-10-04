import 'package:bloc_counter_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter transforms events and survives a parent rebuild', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (var count = 1; count <= 7; count++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(
        find.text('The counter is ${count == 7 ? 10000 : count}'),
        findsOneWidget,
      );
    }

    tester.element(find.byType(Home)).markNeedsBuild();
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('The counter is 8'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('The counter is 10000'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
