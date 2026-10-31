import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mycatatan/main.dart';
import 'package:mycatatan/widgets/category_filter.dart';

Future<void> _login(WidgetTester tester) async {
  await tester.pumpWidget(const MyCatatanApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();

  await _tapVisible(tester, find.text('Masuk'));
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  final Finder scrollView = find.byType(SingleChildScrollView);

  for (int attempt = 0; attempt < 5; attempt++) {
    if (finder.hitTestable().evaluate().isNotEmpty) break;
    await tester.drag(scrollView.last, const Offset(0, -180));
    await tester.pumpAndSettle();
  }

  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Layout tetap rapi di layar kecil', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _login(tester);
    expect(find.text('Halo, Ahmad! 👋'), findsOneWidget);

    // Buka detail lalu gunakan tombol back sistem.
    await tester.tap(find.text('Ide Aplikasi'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Catatan'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Halo, Ahmad! 👋'), findsOneWidget);

    await tester.tap(find.byTooltip('Tambah catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Catatan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Ahmad Fauzi'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Arsip'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Arsip masih kosong'), findsOneWidget);
  });

  testWidgets('Alur lengkap catatan: cari, tambah, edit, arsip, hapus', (
    WidgetTester tester,
  ) async {
    await _login(tester);

    expect(find.text('Halo, Ahmad! 👋'), findsOneWidget);
    expect(find.text('Ide Aplikasi'), findsOneWidget);

    // Pencarian langsung.
    await tester.enterText(find.byType(TextField).first, 'Kuliah');
    await tester.pumpAndSettle();
    expect(find.text('Catatan Kuliah'), findsOneWidget);
    expect(find.text('Ide Aplikasi'), findsNothing);

    await tester.tap(find.byTooltip('Hapus pencarian'));
    await tester.pumpAndSettle();
    expect(find.text('Ide Aplikasi'), findsOneWidget);

    // Filter kategori.
    await tester.tap(
      find.descendant(
        of: find.byType(CategoryFilter),
        matching: find.text('Kerja'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rencana Mingguan'), findsOneWidget);
    expect(find.text('Ide Aplikasi'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(CategoryFilter),
        matching: find.text('Kuliah'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Catatan Kuliah'), findsOneWidget);
    expect(find.text('Rencana Mingguan'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(CategoryFilter),
        matching: find.text('Semua'),
      ),
    );
    await tester.pumpAndSettle();

    // Tambah catatan.
    await tester.tap(find.byTooltip('Tambah catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Tambah Catatan'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Uji Otomatis',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Isi catatan yang dibuat dari pengujian alur aplikasi.',
    );
    await _tapVisible(tester, find.text('Simpan Catatan'));

    expect(find.text('Detail Catatan'), findsOneWidget);
    expect(find.text('Catatan Uji Otomatis'), findsOneWidget);

    // Kembali ke beranda, catatan baru tersimpan.
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan Uji Otomatis'), findsOneWidget);

    // Edit catatan.
    await tester.tap(find.text('Catatan Uji Otomatis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Catatan Uji Sudah Diedit',
    );
    await _tapVisible(tester, find.text('Simpan Perubahan'));
    expect(find.text('Catatan Uji Sudah Diedit'), findsOneWidget);

    // Arsipkan catatan.
    await tester.tap(find.byTooltip('Arsipkan catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Diarsipkan'), findsOneWidget);

    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan Uji Sudah Diedit'), findsNothing);

    await tester.tap(find.text('Arsip'));
    await tester.pumpAndSettle();
    expect(find.text('Catatan Uji Sudah Diedit'), findsOneWidget);

    // Hapus catatan dari arsip.
    await tester.tap(find.text('Catatan Uji Sudah Diedit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus catatan?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan Uji Sudah Diedit'), findsNothing);
    expect(find.text('Arsip masih kosong'), findsOneWidget);
  });
}
