import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_mylaundry/main.dart';

void main() {
  testWidgets('Customer App Initial UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CustomerApp());

    // Verify that the welcome text is displayed.
    expect(find.text('Bersih, Cepat, dan Wangi! ✨'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);

    // Tap the button and trigger a frame.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
  });
}
