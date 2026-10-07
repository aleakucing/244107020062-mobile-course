import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:campus_notify/data/token_store.dart";
import "package:campus_notify/main.dart";
import "package:campus_notify/providers/auth_provider.dart";

class FakeTokenStore extends SecureTokenStore {
  FakeTokenStore({this.access});
  String? access;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => null;

  @override
  Future<void> save(
      {required String access, required String refresh}) async {
    this.access = access;
  }

  @override
  Future<void> clear() async => access = null;
}

Future<void> loadRealFonts() async {
  const dir = "C:/flutter/bin/cache/artifacts/material_fonts";
  ByteData bytes(String name) {
    final data = File("$dir/$name").readAsBytesSync();
    return ByteData.sublistView(data);
  }

  final loader = FontLoader("Roboto")
    ..addFont(Future.value(bytes("roboto-regular.ttf")))
    ..addFont(Future.value(bytes("roboto-medium.ttf")))
    ..addFont(Future.value(bytes("roboto-bold.ttf")));
  final iconLoader = FontLoader("MaterialIcons")
    ..addFont(Future.value(bytes("materialicons-regular.otf")));
  await loader.load();
  await iconLoader.load();
}

Future<void> pumpPhone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  await loadRealFonts();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(FakeTokenStore()),
      ],
      child: const CampusApp(enablePush: false),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 600));
}

Future<void> loginMasuk(WidgetTester tester) async {
  await tester.tap(find.text("Masuk"));
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets("golden halaman login", (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    expect(find.text("Masuk Kampus"), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile("goldens/login.png"),
    );
  });

  testWidgets("golden beranda pengumuman", (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loginMasuk(tester);
    expect(find.text("Pengumuman Kampus"), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile("goldens/beranda.png"),
    );
  });

  testWidgets("golden detail pengumuman", (tester) async {
    await pumpPhone(tester);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loginMasuk(tester);
    await tester.tap(find.text("Jadwal kuliah berubah"));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Detail Pengumuman"), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile("goldens/detail.png"),
    );
  });
}
