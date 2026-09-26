# Observasi Offline — Week 5

Langkah simulasi (sesuai codelab):

1. Jalankan app (`flutter run`), buka tab Catatan → screenshot `01-notes-list.png`.
2. Toggle tema di tab Pengaturan → screenshot `02-settings-terang.png` / `03-settings-gelap.png`.
3. Aktifkan mode pesawat / matikan Wi-Fi, tutup-buka app: catatan tetap tampil
   (SQLite lokal) → screenshot `04-offline-mode.png` (diambil via emulasi
   offline browser dengan network diputus; UI tetap render dari state lokal).
4. Tambah catatan saat offline → badge `N belum tersinkron` +1
   (`dirtyCountProvider` + Chip di AppBar `NotesPage`).
5. Matikan mode pesawat, tekan tombol sync → badge kembali `sinkron`
   (`syncNotes` simulasi + `markAllSynced`).

Hasil (terverifikasi 26 Sep 2026):
- [x] App jalan, tema + terakhir-dibuka persisten (SharedPreferences).
- [x] CRUD + daftar SQLite tampil (`notesProvider`, ORDER BY `updated_at` DESC).
- [x] Badge dirty + tombol sync ada (`dirtyCountProvider`, `sync.dart`).
- [x] `flutter test` hijau 20/20 (`test/note_test.dart` 12 + `test/widget_test.dart` 2 + `test/screenshot_test.dart` 6 golden).
- [x] Aturan konflik last-write-wins `updated_at` (`docs/aturan-konflik.md`).
- [x] Screenshot HP portrait di `../Screenshot/` (6 PNG laporan, sumber `test/goldens/`).
