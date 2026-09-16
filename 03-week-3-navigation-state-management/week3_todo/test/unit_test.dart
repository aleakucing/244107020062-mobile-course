import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  group('StatsNotifier Unit Tests', () {
    setUp(() {
      // Set delay ke Duration.zero agar pengujian berjalan cepat
      StatsNotifier.networkDelay = Duration.zero;
    });

    tearDown(() {
      StatsNotifier.forceErrorForTesting = null;
      StatsNotifier.networkDelay = const Duration(seconds: 2);
    });

    test('Kondisi Sukses: Mengembalikan 3 item data statistik', () async {
      StatsNotifier.forceErrorForTesting = false;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final completer = Completer<List<StatItem>>();

      container.listen<AsyncValue<List<StatItem>>>(
        statsProvider,
        (previous, next) {
          if (next.hasValue && !completer.isCompleted) {
            completer.complete(next.value!);
          }
        },
      );

      final result = await completer.future.timeout(const Duration(seconds: 3));

      expect(result.length, 3);
      expect(result[0].label, 'Total Tugas Selesai');
      expect(result[0].value, '24');
      expect(container.read(statsProvider).hasValue, isTrue);
    });

    test('Kondisi Gagal: Menangkap exception saat terjadi kegagalan jaringan (Simulasi 30%)', () async {
      StatsNotifier.forceErrorForTesting = true;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final completer = Completer<AsyncValue<List<StatItem>>>();

      container.listen<AsyncValue<List<StatItem>>>(
        statsProvider,
        (previous, next) {
          if (next.hasError && !completer.isCompleted) {
            completer.complete(next);
          }
        },
        onError: (_, _) {
          if (!completer.isCompleted) {
            completer.complete(container.read(statsProvider));
          }
        },
      );

      final state = await completer.future.timeout(const Duration(seconds: 3));

      expect(state.hasError, isTrue);
      expect(state.error.toString(), contains('Gagal menghubungi server statistik'));
    });

    test('Metode Refresh: Berhasil memulihkan state ke data sukses', () async {
      StatsNotifier.forceErrorForTesting = true;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final errorCompleter = Completer<void>();

      container.listen<AsyncValue<List<StatItem>>>(
        statsProvider,
        (previous, next) {
          if (next.hasError && !errorCompleter.isCompleted) {
            errorCompleter.complete();
          }
        },
        onError: (_, _) {
          if (!errorCompleter.isCompleted) {
            errorCompleter.complete();
          }
        },
      );

      await errorCompleter.future.timeout(const Duration(seconds: 3));
      expect(container.read(statsProvider).hasError, isTrue);

      // Ubah flag testing menjadi sukses dan panggil refresh()
      StatsNotifier.forceErrorForTesting = false;
      await container.read(statsProvider.notifier).refresh();

      // Verifikasi data berhasil dimuat setelah refresh
      final state = container.read(statsProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.length, 3);
      expect(state.value?[0].label, 'Total Tugas Selesai');
    });
  });
}
