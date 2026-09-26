# Screenshots — Week 5

PNG di folder ini diambil asli dari app (Chrome, build web) via agent-browser, tanpa rekayasa.

| File | Isi | Status praktikum |
|---|---|---|
| `01-notes-list.png` | Tab Catatan di web: state error + tombol `Coba lagi` | Memenuhi sebagian: bukti state **error** (`friendlyDbError`). sqflite tidak jalan di web, daftar asli hanya tampil di HP |
| `02-settings-terang.png` | Tab Pengaturan tema terang + terakhir dibuka | Memenuhi (toggle tema + persistensi SharedPreferences) |
| `03-settings-gelap.png` | Tab Pengaturan tema gelap (switch ON) | Memenuhi (persistensi tema) |
| `04-offline-mode.png` | Tab Catatan dengan network diputus (`set offline on`) | Bukti parsial: UI tetap render dari state lokal tanpa network |

Belum ada — wajib difoto di HP (Infinix sempat terputus saat pengambilan):
- `05-dirty-sebelum.png`: tambah 2 catatan saat mode pesawat ON → badge `2 belum tersinkron`.
- `06-dirty-sesudah.png`: mode pesawat OFF → tekan tombol sync → badge `sinkron`.
- Daftar catatan SQLite + badge: hanya tampil di HP, bukan di web.

Cara ambil di HP:
1. Sambungkan HP, `flutter run` (debug).
2. Mode pesawat ON → tambah 2 catatan via tombol + → screenshot (`05`).
3. Mode pesawat OFF → tekan ikon sync di AppBar → screenshot (`06`).
