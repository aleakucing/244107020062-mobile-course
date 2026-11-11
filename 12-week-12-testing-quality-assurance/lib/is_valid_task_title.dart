/// Aturan validasi judul tugas:
/// Judul valid jika berisi minimal 1 karakter non-spasi dan tidak melebihi 100 karakter.
bool isValidTaskTitle(String value) {
  final trimmed = value.trim();
  return trimmed.isNotEmpty && trimmed.length <= 100;
}
