import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/game_controller.dart';

void main() {
  testWidgets('Splash screen shows PrimeTap text', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameController(),
        child: const PrimeTapApp(),
      ),
    );

    expect(find.text('PrimeTap'), findsOneWidget);
  });
}
