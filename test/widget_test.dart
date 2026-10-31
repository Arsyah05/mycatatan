import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mycatatan/main.dart';

void main() {
  testWidgets('Splash screen tampil lalu berpindah ke login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyCatatanApp());

    expect(find.text('MyCatatan'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Masuk untuk melanjutkan'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
  });
}
