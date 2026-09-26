# Aturan Konflik Sinkronisasi — Week 5

**Aturan: last-write-wins berdasarkan `updated_at`.**

- Setiap tulis lokal mengisi `updatedAt = DateTime.now()` dan `dirty = 1`
  (lihat `NoteRepository.addNote`).
- Saat online, `syncNotes` mengunggah catatan `dirty = 1` berurutan;
  bila server jawab 2xx → `markAllSynced()` (`dirty = 0`).
- Konflik dua arah: baris dengan `updated_at` paling baru menang;
  tanpa aturan eksplisit, sync dua arah menimpa data diam-diam.

Status implementasi: `countDirty` + `markAllSynced` + `syncNotes`
(`lib/data/sync.dart`, delay 1 detik) + `updateNote` + provider
(`lib/data/notes_providers.dart`) + UI badge/tombol sync
(`lib/pages/notes_page.dart`) selesai dan diuji (`test/note_test.dart` 11 pass).
Cache-first posts (`cached_posts`) tetap TODO refactoring challenge.
