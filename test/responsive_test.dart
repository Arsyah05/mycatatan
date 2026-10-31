import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mycatatan/main.dart';
import 'package:mycatatan/screens/home_screen.dart';
import 'package:mycatatan/theme/app_theme.dart';

Future<void> _pumpSplash(
  WidgetTester tester,
  Size size, {
  double topPadding = 0,
  double bottomPadding = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;

  if (topPadding > 0 || bottomPadding > 0) {
    tester.view.padding = FakeViewPadding(
      top: topPadding,
      bottom: bottomPadding,
    );
    tester.view.viewPadding = FakeViewPadding(
      top: topPadding,
      bottom: bottomPadding,
    );
  }

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);

  await tester.pumpWidget(const MyCatatanApp());
  await tester.pump(const Duration(milliseconds: 900));
}

Future<void> _pumpHome(
  WidgetTester tester,
  Size size, {
  double topPadding = 0,
  double bottomPadding = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;

  if (topPadding > 0 || bottomPadding > 0) {
    tester.view.padding = FakeViewPadding(
      top: topPadding,
      bottom: bottomPadding,
    );
    tester.view.viewPadding = FakeViewPadding(
      top: topPadding,
      bottom: bottomPadding,
    );
  }

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);

  await tester.pumpWidget(
    MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Splash tidak overflow di 568x320', (WidgetTester tester) async {
    await _pumpSplash(tester, const Size(568, 320));

    expect(find.text('MyCatatan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Splash tidak overflow di 640x360 dengan system bar', (
    WidgetTester tester,
  ) async {
    await _pumpSplash(
      tester,
      const Size(640, 360),
      topPadding: 24,
      bottomPadding: 24,
    );

    expect(find.text('MyCatatan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home menampilkan daftar catatan di 568x320', (
    WidgetTester tester,
  ) async {
    await _pumpHome(tester, const Size(568, 320));

    expect(find.text('Halo, Ahmad! 👋'), findsOneWidget);
    expect(find.text('Ide Aplikasi'), findsOneWidget);

    final Finder noteList = find.byType(ListView).last;
    expect(tester.getSize(noteList).height, greaterThanOrEqualTo(90));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home menampilkan daftar catatan di 640x360 dengan system bar', (
    WidgetTester tester,
  ) async {
    await _pumpHome(
      tester,
      const Size(640, 360),
      topPadding: 24,
      bottomPadding: 24,
    );

    expect(find.text('Halo, Ahmad! 👋'), findsOneWidget);
    expect(find.text('Ide Aplikasi'), findsOneWidget);

    final Finder noteList = find.byType(ListView).last;
    expect(tester.getSize(noteList).height, greaterThanOrEqualTo(90));
    expect(tester.takeException(), isNull);
  });
}
