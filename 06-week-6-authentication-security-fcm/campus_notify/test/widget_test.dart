import "package:flutter/material.dart";
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

Widget appWith({String? access}) => ProviderScope(
      overrides: [
        tokenStoreProvider.overrideWithValue(
            FakeTokenStore(access: access)),
      ],
      child: const CampusApp(enablePush: false),
    );

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets("belum login selalu diarahkan ke halaman login",
      (tester) async {
    await tester.pumpWidget(appWith());
    await settle(tester);
    expect(find.text("Masuk Kampus"), findsOneWidget);
    expect(find.text("Pengumuman Kampus"), findsNothing);
  });

  testWidgets("login valid membuka beranda pengumuman", (tester) async {
    await tester.pumpWidget(appWith());
    await settle(tester);
    await tester.tap(find.text("Masuk"));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Pengumuman Kampus"), findsOneWidget);
    expect(find.text("Jadwal kuliah berubah"), findsOneWidget);
  });

  testWidgets("klik pengumuman membuka halaman detail", (tester) async {
    await tester.pumpWidget(appWith());
    await settle(tester);
    await tester.tap(find.text("Masuk"));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text("Jadwal kuliah berubah"));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Detail Pengumuman"), findsOneWidget);
    expect(find.text("3 Okt 2026"), findsOneWidget);
  });
}
