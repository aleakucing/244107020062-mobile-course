// Fungsi murni untuk formatting + pesan error ramah pengguna.
// Boleh diuji tanpa widget, tanpa database, tanpa jaringan.

/// Format tanggal catatan untuk list, tanpa memaksa locale tertentu.
String formatNoteDate(DateTime dt) {
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// Pesan ramah untuk error database lokal.
String friendlyDbError(Object error) =>
    'Gagal memuat catatan lokal ($error). Data SQLite tetap aman, coba lagi.';

/// Format info "terakhir dibuka" untuk settings.
String formatLastOpened(String? iso) {
  if (iso == null) return 'Belum pernah dicatat';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return formatNoteDate(dt);
}
