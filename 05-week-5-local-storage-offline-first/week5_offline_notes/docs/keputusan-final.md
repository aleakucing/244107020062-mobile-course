# Keputusan Final + Verifikasi AI — Week 5

Rekomendasi final (dipakai di project):

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi (tema, terakhir dibuka) | SharedPreferences | Key-value kecil, API simpel, cukup |
| Catatan (CRUD 1000+) | sqflite (SQLite) | Query + sorting `updated_at` + `dirty flag` untuk sync; trade-off boilerplate sepadan |

## AI Verification Checklist

- [x] AI menempatkan daftar catatan di SharedPreferences? **Ditolak.** Koleksi = SQLite (`lib/data/repositories/note_repository.dart`). JSON satu string di prefs rapuh/lambat untuk query dan update parsial.
- [x] Skema AI mendukung antrean sync (`dirty` / `updated_at`)? **Ya, dipakai.** `Note.dirty`, `countDirty()`, `markAllSynced()` ada. `syncNotes` + `cached_posts` belum diimplementasi (lihat observasi-offline.md).
- [x] Klaim "real-time" AI didukung stream? **Ditolak sebagian.** sqflite polos tanpa stream; klaim real-time butuh Drift `watch()` atau Stream wrapper. Project ini pakai `invalidate` provider (cukup untuk codelab).
- [x] Estimasi boilerplate AI masuk akal? **Ya.** `flutter pub add flutter_riverpod shared_preferences sqflite path` + skema `db.dart` sesuai estimasi; tidak ada migrasi rumit karena `version: 1`.
- Keputusan final boleh beda dari AI selama berargumen: **tetap SharedPreferences + SQLite** sesuai codelab industri umum.
