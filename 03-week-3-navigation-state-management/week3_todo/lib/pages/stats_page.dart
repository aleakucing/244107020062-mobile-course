import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

/// Halaman Statistik (StatsPage) mengimplementasikan ConsumerWidget
/// Mengadopsi Stripe Design System dari OpenDesign:
/// - Background: Crisp Canvas #F6F9FC
/// - Text: Stripe Deep Navy #0A2540 & Slate #425466
/// - Accent: Stripe Signature Blurple #635BFF
/// - Card: Pure White #FFFFFF dengan diffuse elevation shadow khas Stripe
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  // --- Stripe Design System Tokens ---
  static const Color bgCanvas = Color(0xFFF6F9FC); // Stripe Light Canvas
  static const Color bgSurface = Colors.white; // Card Pure White
  static const Color borderSubtle = Color(0xFFE3E8EE); // Stripe Slate Border
  static const Color accentStripe = Color(0xFF635BFF); // Stripe Blurple (Primary Accent)
  static const Color accentCyan = Color(0xFF00D4FF); // Stripe Cyan Glow
  static const Color textNavy = Color(0xFF0A2540); // Stripe Signature Deep Navy (Primary Text)
  static const Color textSlate = Color(0xFF425466); // Stripe Body Text
  static const Color textMuted = Color(0xFF697386); // Stripe Subdued Label
  static const Color statusGreen = Color(0xFF00875A); // Stripe Success Green
  static const Color statusCrimson = Color(0xFFDF1B41); // Stripe Error Crimson

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ref.watch hanya digunakan di dalam method build untuk memantau perubahan state
    final AsyncValue<List<StatItem>> statsAsync = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: bgCanvas,
      // Membatasi lebar tampilan di browser Chrome (max 480px) agar proporsional
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              _buildStripeHeader(ref),
              Expanded(
                // 2. Pola .when() menangani ketiga kondisi AsyncValue secara komprehensif
                child: statsAsync.when(
                  loading: () => _buildLoadingState(),
                  error: (error, _) => _buildErrorState(context, ref, error),
                  data: (stats) => _buildSuccessState(context, ref, stats),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header Bersih Bergaya Stripe Dashboard
  Widget _buildStripeHeader(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderSubtle, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentStripe.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STRIPE DESIGN SYSTEM',
                      style: TextStyle(
                        color: accentStripe,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Statistik & Metrik',
                style: TextStyle(
                  color: textNavy,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          // ref.read digunakan di dalam callback onPressed (bukan di build)
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: bgCanvas,
              side: const BorderSide(color: borderSubtle),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.sync_rounded, color: textSlate, size: 20),
            tooltip: 'Sinkronkan Data',
            onPressed: () => ref.read(statsProvider.notifier).refresh(),
          ),
        ],
      ),
    );
  }

  /// Loading State: Stripe Blurple Spinner dengan Kartu Putih Elegan
  Widget _buildLoadingState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        decoration: BoxDecoration(
          color: bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderSubtle),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F32325D),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(accentStripe),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat Analisis Data...',
              style: TextStyle(
                color: textNavy,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Simulasi latensi asinkron (2 detik)',
              style: TextStyle(color: textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// Error State: Kartu Alert Stripe Crimson dengan Tombol Retry Blurple
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: bgSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: statusCrimson.withValues(alpha: 0.3)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14DF1B41),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusCrimson.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: statusCrimson, size: 28),
              ),
              const SizedBox(height: 18),
              const Text(
                'Gagal Menghubungi Layanan',
                style: TextStyle(
                  color: textNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textSlate,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentStripe,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  // ref.invalidate digunakan untuk memicu ulang build() provider
                  onPressed: () => ref.invalidate(statsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Success State: Header Gradient Card + ListView 3 Item Statistik
  Widget _buildSuccessState(
      BuildContext context, WidgetRef ref, List<StatItem> stats) {
    return RefreshIndicator(
      color: accentStripe,
      backgroundColor: Colors.white,
      onRefresh: () async {
        await ref.read(statsProvider.notifier).refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // 1. Stripe Aurora Gradient Card (Ringkasan Performa)
          _buildStripeAuroraCard(stats),

          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'RINGKASAN METRIK AKTIVITAS',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. ListView 3 Item Statistik sesuai requirement
          ...stats.asMap().entries.map((entry) {
            final int index = entry.key;
            final StatItem item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildStripeMetricCard(item, index),
            );
          }),
        ],
      ),
    );
  }

  /// Kartu Ringkasan Bergaya Stripe Gradient Mesh (Aurora)
  Widget _buildStripeAuroraCard(List<StatItem> stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF635BFF), // Stripe Blurple
            Color(0xFF0073F5), // Stripe Deep Royal Blue
            Color(0xFF00D4FF), // Stripe Cyan
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33635BFF),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Indeks Kinerja Terpadu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'REAL-TIME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '92.4%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pencapaian tugas akademik minggu ini melampaui target standar.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.92,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu Metrik Stripe dengan Elevation Shadow & Border Lembut
  Widget _buildStripeMetricCard(StatItem item, int index) {
    final Color indicatorColor = item.isPositive ? statusGreen : statusCrimson;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D32325D),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color: textSlate,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: indicatorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isPositive ? 'OPTIMAL' : 'PERHATIAN',
                  style: TextStyle(
                    color: indicatorColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: const TextStyle(
              color: textNavy,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 5,
              backgroundColor: bgCanvas,
              valueColor: AlwaysStoppedAnimation<Color>(
                item.isPositive ? accentStripe : statusCrimson,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                item.isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: indicatorColor,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: indicatorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
