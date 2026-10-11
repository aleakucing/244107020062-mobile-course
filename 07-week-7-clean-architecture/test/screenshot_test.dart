import 'dart:io';

import 'package:clean_notes/core/failures.dart';
import 'package:clean_notes/features/notes/presentation/providers/notes_providers.dart';
import 'package:clean_notes/features/settings/domain/repositories/settings_repository.dart';
import 'package:clean_notes/features/settings/presentation/providers/settings_providers.dart';
import 'package:clean_notes/main.dart';
import 'package:clean_notes/screenshot_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden test penghasil screenshot HP portrait (390x844 @3x).
///
/// Dijalankan dengan `flutter test test/screenshot_test.dart --update-goldens`
/// untuk (re)generasi, lalu tanpa flag untuk verifikasi. Data di-seed
/// deterministik agar golden stabil.
class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({required this.dark});
  bool dark;

  @override
  Future<({bool darkMode, Failure? failure})> getDarkMode() async =>
      (darkMode: dark, failure: null);

  @override
  Future<({Failure? failure})> setDarkMode(bool value) async {
    dark = value;
    return (failure: null);
  }

  @override
  Future<({String? lastOpened, Failure? failure})> getLastOpened() async =>
      (lastOpened: '2026-09-26T10:00:00.000', failure: null);

  @override
  Future<({Failure? failure})> markOpenedNow() async => (failure: null);
}

Future<void> loadRealFonts() async {
  const dir = 'C:/flutter/bin/cache/artifacts/material_fonts';
  ByteData bytes(String name) {
    final data = File('$dir/$name').readAsBytesSync();
    return ByteData.sublistView(data);
  }

  final loader = FontLoader('Roboto')
    ..addFont(Future.value(bytes('roboto-regular.ttf')))
    ..addFont(Future.value(bytes('roboto-medium.ttf')))
    ..addFont(Future.value(bytes('roboto-bold.ttf')));
  final iconLoader = FontLoader('MaterialIcons')
    ..addFont(Future.value(bytes('materialicons-regular.otf')));
  await loader.load();
  await iconLoader.load();
}

Future<void> pumpPhone(WidgetTester tester, {bool dark = false}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  await loadRealFonts();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        noteRepositoryProvider.overrideWithValue(SeededNoteRepository()),
        settingsRepositoryProvider
            .overrideWithValue(FakeSettingsRepository(dark: dark)),
        lastOpenedProvider.overrideWithValue(
          const AsyncValue.data('2026-09-26T10:00:00.000'),
        ),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('golden daftar catatan + badge dirty', (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text('Belanja mingguan'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/daftar_catatan.png'),
    );
  });

  testWidgets('golden dialog tambah catatan', (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.tap(find.byTooltip('Tambah catatan'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Catatan baru'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/dialog_tambah.png'),
    );
  });

  testWidgets('golden pengaturan terang', (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.tap(find.text('Pengaturan'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tema gelap'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pengaturan_terang.png'),
    );
  });

  testWidgets('golden pengaturan gelap', (tester) async {
    await pumpPhone(tester, dark: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.tap(find.text('Pengaturan'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pengaturan_gelap.png'),
    );
  });

  testWidgets('golden badge sebelum sync', (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.textContaining('belum tersinkron'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/dirty_sebelum.png'),
    );
  });

  testWidgets('golden badge sesudah sync', (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.tap(find.byTooltip('Sinkronkan'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('sinkron'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/dirty_sesudah.png'),
    );
  });
}
