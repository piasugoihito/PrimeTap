import 'package:flutter_test/flutter_test.dart';
import 'package:merge_tap_game/main.dart';

void main() {
  testWidgets('Start screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PrimeTapApp());
    expect(find.text('PrimeTap'), findsOneWidget);
  });
}
