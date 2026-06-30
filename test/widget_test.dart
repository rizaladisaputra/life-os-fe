// Basic smoke test untuk LifeOS App
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_app/main.dart';

void main() {
  testWidgets('LifeOS app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LifeOSApp(),
      ),
    );
    // Verifikasi app berhasil di-render
    expect(find.byType(LifeOSApp), findsOneWidget);
  });
}
