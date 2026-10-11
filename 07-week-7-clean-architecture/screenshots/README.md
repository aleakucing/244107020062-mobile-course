# Screenshots HP portrait (390x844 @3x)

Dihasilkan dari `test/screenshot_test.dart` (golden test dengan repository
seed in-memory, tanpa SQLite asli) — teknik yang sama seperti Week 5.
Bukan screenshot jendela desktop: view di-set eksplisit ke ukuran HP
(`Size(1170, 2532)`, pixel ratio 3.0).

- `01-notes-list.png` — daftar catatan + badge "2 belum tersinkron".
- `02-dialog-tambah.png` — dialog tambah catatan.
- `03-settings-terang.png` / `04-settings-gelap.png` — toggle tema.
- `05-dirty-sebelum.png` / `06-dirty-sesudah.png` — badge sebelum/sesudah sync.

Behavior identik dengan Week 5 (UI sama, struktur folder beda).
Untuk jalan di HP fisik: colok HP (USB debugging) lalu
`flutter run` pada device Android; di Chrome/Windows pakai
`flutter run -t lib/screenshot_main.dart` karena sqflite tidak tersedia di web.
