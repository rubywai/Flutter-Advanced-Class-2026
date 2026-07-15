import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:online_shop_app_codex/main.dart';

void main() {
  testWidgets('shows online shop home actions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OnlineShopApp()));

    expect(find.text('Online Shop'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
