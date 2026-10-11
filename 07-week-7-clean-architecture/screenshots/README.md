# Before/after — behavior identik

UI tidak berubah setelah refactor (definisi selesai codelab: uji manual
±5 menit tiap fitur + screenshot).

- `01-notes-list.png` — daftar catatan (before: Week 5, after: Week 7 identik).
- `02-settings-terang.png` / `03-settings-gelap.png` — toggle tema terang/gelap.
- `04-offline-mode.png` — badge dirty + sinkron simulasi.

Sumber before: `05-week-5-local-storage-offline-first/week5_offline_notes/screenshots/`.
After: struktur folder beda (`lib/features/...`), tampilan sama.
Bukti uji: `flutter test` 14/14 + `flutter analyze` bersih.
