# Offline Notes — Week 5: Local Storage & Offline First

Tujuan: preferensi (SharedPreferences) + CRUD catatan (SQLite/sqflite) + pola offline-first via repository + Riverpod.

## Fitur utama

- Toggle tema gelap/terang + waktu terakhir dibuka (SharedPreferences via `PrefsRepository` + `darkModeProvider`).
- Skema + repository SQLite siap: `fetchNotes` (`ORDER BY updated_at DESC`), `addNote` (`dirty=1`), `deleteNote`, `countDirty`, `markAllSynced`.
- Aturan konflik: last-write-wins `updated_at` (lihat `docs/aturan-konflik.md`).

## Stack

Flutter + `flutter_riverpod`, `shared_preferences`, `sqflite`, `path`.

## Cara menjalankan

```
flutter pub get
flutter run            # HP/emulator (disarankan untuk SharedPreferences/sqflite)
flutter run -d chrome  # web (sebagian plugin lokal terbatas di web)
flutter analyze
flutter test
```

## Hasil yang dicapai

- [x] Layer data + preferensi selesai dan terdokumentasi di `docs/`.
- [x] UI catatan (`lib/pages/notes_page.dart` + `lib/data/notes_providers.dart`) + `syncNotes` (`lib/data/sync.dart`) + `test/note_test.dart` selesai.
- [x] `flutter analyze`: No issues found. `flutter test`: 13/13 pass (11 note_test + 2 widget_test).
- Screenshot kondisi saat ini di `screenshots/` (02/03 settings valid; 01/04 perlu foto ulang setelah CRUD — lihat `screenshots/README.md`).
