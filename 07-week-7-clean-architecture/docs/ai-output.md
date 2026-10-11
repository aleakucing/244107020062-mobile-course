# Ringkasan output AI (simulasi terverifikasi)

> Catatan: output di bawah adalah rekonstruksi usulan generik AI assistant
> untuk prompt di `AI_PROMPT.md`, ditulis ulang agar bisa diverifikasi
> baris-per-baris dengan grep. Tidak ada kode yang disalin mentah dari AI
> tanpa verifikasi.

## Usulan AI (umum)

1. Struktur `lib/features/{notes,settings,auth}/{data,domain,presentation}`
   + `lib/core/` — setuju, dipakai.
2. `domain/` berisi entity + repository interface + use case per operasi
   (`GetNotes`, `AddNote`, `UpdateNote`, `DeleteNote`, `SyncNotes`,
   `GetDarkMode`, `SetDarkMode`, ...) — **sebagian ditolak** (lihat bawah).
3. `data/` berisi model + repository impl + datasource (`db.dart`,
   `prefs_datasource.dart`) — setuju sebagian; datasource dilebur ke
   repository impl agar YAGNI (project kecil, 1 tabel + 2 key prefs).
4. Wiring DI dengan Riverpod `Provider` + `AsyncNotifierProvider` —
   setuju, dipakai persis.
5. GoRouter untuk semua navigasi + `Either` via `fpdart` —
   **ditolak** (lihat alasan).

## Hasil verifikasi checklist (wajib codelab)

- [x] Interface repository di `domain`, implementasi di `data`?
  Ya. `features/notes/domain/repositories/note_repository.dart`
  vs `features/notes/data/repositories/note_repository_impl.dart`.
  Sama untuk settings.
- [x] `domain` bebas import Flutter/Dio/SQLite/Firebase?
  Ya. Buktikan: `grep` pada `lib/*/domain + lib/core` → NOL hasil.
- [x] AI membuat use case untuk tiap CRUD satu-baris?
  Ya (AI mengusulkan `UpdateNote`, `DeleteNote`, `GetDarkMode`...).
  Ditolak: CRUD satu-baris langsung repository → notifier.
  Hanya `GetNotes`, `AddNote` (ada validasi), `SyncNotes` (operasi bisnis)
  yang jadi use case. Alasan tertulis di `keputusan-final.md`.
- [x] Entity bebas mapping?
  Ya. `toMap/fromMap` hanya di `NoteModel`. Entity `Note` murni.
- [x] Wiring DI terpusat, widget tidak `new` repository?
  Ya. Hanya `notes_providers.dart` dan `settings_providers.dart`
  yang membuat impl. Pages hanya `ref.watch/read`.
