import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:performance_optimization/cached_repository.dart';
import 'package:performance_optimization/main.dart';
import 'package:performance_optimization/optimized_list_page.dart';

void main() {
  group('CachedItemRepository Tests', () {
    test('menyimpan cache halaman yang telah di-fetch (Cache Hit)', () async {
      final repo = CachedItemRepository(latency: Duration.zero);

      final page1 = await repo.fetchPage(1, pageSize: 5);
      expect(page1.length, 5);
      expect(repo.getCachedItems().length, 5);

      // Fetch kedua kali harus membaca dari memory cache tanpa overhead
      final page1Cached = await repo.fetchPage(1, pageSize: 5);
      expect(identical(page1, page1Cached), isTrue);
    });

    test('clearCache mengosongkan cache in-memory secara tuntas', () async {
      final repo = CachedItemRepository(latency: Duration.zero);
      await repo.fetchPage(1, pageSize: 5);
      expect(repo.getCachedItems().isNotEmpty, isTrue);

      repo.clearCache();
      expect(repo.getCachedItems(), isEmpty);
    });
  });

  group('OptimizedListPage Widget Tests', () {
    testWidgets('merender halaman awal dan daftar item berkinerja tinggi', (
      tester,
    ) async {
      final repo = CachedItemRepository(latency: Duration.zero);

      await tester.pumpWidget(MyApp(repository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Optimasi Performa (60 FPS)'), findsOneWidget);
      expect(find.byType(OptimizedFeedTile), findsWidgets);
      expect(find.text('Laporan Aktivitas Mahasiswa #1'), findsOneWidget);
    });

    testWidgets(
      'memastikan item dibungkus RepaintBoundary untuk isolasi repaint',
      (tester) async {
        final repo = CachedItemRepository(latency: Duration.zero);

        await tester.pumpWidget(MyApp(repository: repo));
        await tester.pumpAndSettle();

        final repaintFinder = find.descendant(
          of: find.byType(OptimizedFeedTile),
          matching: find.byType(RepaintBoundary),
        );
        expect(repaintFinder, findsWidgets);
      },
    );

    testWidgets(
      'melakukan lazy loading halaman berikutnya saat scroll ke bawah',
      (tester) async {
        final repo = CachedItemRepository(latency: Duration.zero);

        await tester.pumpWidget(MyApp(repository: repo));
        await tester.pumpAndSettle();

        // Item awal adalah 15 item
        expect(find.text('Laporan Aktivitas Mahasiswa #1'), findsOneWidget);

        // Scroll ke bawah
        await tester.drag(find.byType(ListView), const Offset(0, -1200));
        await tester.pumpAndSettle();

        // Verifikasi item dari halaman ke-2 berhasil dimuat
        expect(find.text('Laporan Aktivitas Mahasiswa #16'), findsOneWidget);
      },
    );
  });
}
