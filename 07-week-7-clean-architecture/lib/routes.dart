// Konstanta rute aplikasi (tanpa GoRouter — YAGNI untuk 2 tab).
// Bila fitur auth/deep-link ditambahkan, ganti dengan GoRouter
// tanpa mengubah fitur (lihat docs/keputusan-final.md).
abstract class AppRoutes {
  static const notes = '/notes';
  static const settings = '/settings';
}
