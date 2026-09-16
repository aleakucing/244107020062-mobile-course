import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model representasi data statistik individual
class StatItem {
  final String label;
  final String value;
  final String subtitle;
  final bool isPositive;
  final double progress; // Nilai 0.0 - 1.0 untuk indikator progres visual

  const StatItem({
    required this.label,
    required this.value,
    required this.subtitle,
    this.isPositive = true,
    this.progress = 0.75,
  });
}

/// Notifier asinkron untuk mengelola state data statistik
/// Mewarisi [AsyncNotifier] dari flutter_riverpod
class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  /// Flag khusus testing untuk memicu error secara deterministik saat unit test
  static bool? forceErrorForTesting;

  /// Durasi latensi simulasi (default 2 detik sesuai requirements, bisa di-override di test)
  static Duration networkDelay = const Duration(seconds: 2);

  @override
  Future<List<StatItem>> build() async {
    // 1. Simulasi delay latensi jaringan selama 2 detik sesuai requirement
    await Future.delayed(networkDelay);

    // 2. Simulasi probabilitas kegagalan jaringan 30% (Random 0.0 - 1.0 < 0.3)
    final bool shouldFail =
        forceErrorForTesting ?? (Random().nextDouble() < 0.3);

    if (shouldFail) {
      // Melempar exception jika kondisi gagal terpenuhi
      throw Exception('Gagal menghubungi server statistik (Simulasi error 30%)');
    }

    // 3. Mengembalikan 3 item data statistik pada kondisi sukses
    return const [
      StatItem(
        label: 'Total Tugas Selesai',
        value: '24',
        subtitle: '+18% capaian minggu ini',
        isPositive: true,
        progress: 0.82,
      ),
      StatItem(
        label: 'Efisiensi Waktu Kerja',
        value: '92.4%',
        subtitle: '+4.1% melampaui target',
        isPositive: true,
        progress: 0.92,
      ),
      StatItem(
        label: 'Rata-rata Durasi Tugas',
        value: '45 Menit',
        subtitle: '-12 menit lebih cepat dari rata-rata',
        isPositive: true,
        progress: 0.65,
      ),
    ];
  }

  /// Method pembaruan manual (Refresh) yang aman menggunakan AsyncValue.guard
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

/// Provider global yang diekspos ke widget UI
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);
