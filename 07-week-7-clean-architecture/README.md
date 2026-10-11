# Clean Notes — Week 7: Clean Architecture

Refactor `week5_offline_notes` (Week 5) menjadi Clean Architecture
feature-first. Bukan project baru: kode yang sudah jalan dipindah dan
dipisah layer-nya, behavior UI identik.

**Nama:** Muchammad Ibrahim Al Amin — **NIM:** 244107020062

## Tujuan

- Menjelaskan SOLID + separation of concerns dengan contoh Flutter nyata.
- Membedakan feature-first vs layer-first beserta trade-off-nya.
- Menerapkan 3 layer (presentation/domain/data) + dependency rule.
- Membedakan entity vs model, peran repository/use case/DI.
- Menguji use case dengan repository palsu (tanpa DB/jaringan).

## Diagram layer + arah dependensi

```
presentation (widget, notifier, router)
      |
      v  bergantung ke
domain (entity, repository interface, use case, failure)
      ^
      |  diimplementasikan oleh
data (model, repository impl, sqflite, shared_preferences)
```

Aturan emas: dependensi hanya mengarah ke dalam.
`domain` tidak tahu Flutter/Dio/SQLite → bisa di-unit-test murni.

Feature-first yang dipakai:

```
lib/
├── core/
│   ├── failures.dart        # Failure domain (murni Dart)
│   └── format.dart          # format tanggal + pesan error (fungsi murni)
├── features/
│   ├── notes/
│   │   ├── domain/entities/note.dart
│   │   ├── domain/repositories/note_repository.dart  # interface!
│   │   ├── domain/usecases/{get_notes,add_note,sync_notes}.dart
│   │   ├── data/models/note_model.dart               # mapping hanya di sini
│   │   ├── data/local/db.dart
│   │   ├── data/repositories/note_repository_impl.dart
│   │   └── presentation/{providers/notes_providers.dart, pages/notes_page.dart}
│   └── settings/
│       ├── domain/repositories/settings_repository.dart
│       ├── data/repositories/settings_repository_impl.dart
│       └── presentation/{providers/settings_providers.dart, pages/settings_page.dart}
├── routes.dart              # konstanta rute (tanpa GoRouter — YAGNI, lihat docs/)
└── main.dart                # ProviderScope + HomeShell 2 tab
```

## Praktikum 1 — Pemetaan file lama ke layer

| File (Week 5) | Layer saat ini | Masalah |
|---|---|---|
| `lib/pages/notes_page.dart` | presentation | `toLocal()` mentah di widget; sudah tidak ada SQLite langsung (bagus) |
| `lib/pages/settings_page.dart` | presentation | OK, hanya via provider |
| `lib/data/notes_providers.dart` | presentation (state) | OK bila hanya memanggil repository/use case |
| `lib/data/repositories/note_repository.dart` | data (+kontrak tercampur) | interface + implementasi satu kelas; melempar exception mentah |
| `lib/data/local/note.dart` | data (+domain tercampur) | entity + `toMap/fromMap` satu kelas |
| `lib/data/local/db.dart` | data | OK, hanya dipakai repository |
| `lib/data/prefs.dart` | data (+kontrak tercampur) | interface + SharedPreferences satu kelas |
| `lib/data/sync.dart` | domain tercampur | logika sync di fungsi bebas, bukan use case |

Tiga pelanggaran klasik (hasil grep Week 5 → target Week 7 NOL di presentation):

```
# Widget menyentuh jaringan/DB langsung → Week 7: NOL (kecuali wiring DI di providers)
# Logika bisnis di build() (DateFormat/jsonDecode/toIso8601String di pages) → Week 7: NOL
#   formatting pindah ke lib/core/format.dart (fungsi murni, teruji)
# Instansiasi manual Repository(/Dio( di pages/providers) → Week 7: hanya di provider wiring
```

## Fitur utama

- CRUD catatan offline-first (SQLite, `ORDER BY updated_at DESC`, flag `dirty`).
- Badge sinkron + tombol sync simulasi (delay 1 dtk + `markAllSynced`).
- Tema gelap/terang + terakhir dibuka (SharedPreferences via repository).
- Failure ramah pengguna: exception mentah → `Failure.message` sebelum UI.

## Stack

Flutter + `flutter_riverpod`, `sqflite`, `shared_preferences`, `path`.
Tanpa `get_it`/`fpdart`/GoRouter/Firebase — alasan di `docs/keputusan-final.md`.

## Cara menjalankan

```
flutter pub get
flutter run              # HP/emulator (disarankan untuk SQLite/prefs)
flutter analyze          # harus: No issues found!
flutter test             # harus: 14/14 passed
```

## Hasil yang dicapai

- [x] 2 fitur penuh (`notes` + `settings`) terpisah domain/data/presentation.
- [x] Dependency rule terbukti — lihat `docs/verifikasi-grep.txt` (3 grep NOL).
- [x] Behavior identik — `screenshots/` before/after + uji manual.
- [x] 14 test lulus (syarat minimal 2: `test/get_notes_test.dart` sukses + failure).
- [x] 6 golden HP portrait (`test/screenshot_test.dart` + `lib/screenshot_main.dart`,
      dipublikasikan ke `screenshots/01..06`) — teknik sama seperti Week 5.
- [x] AI Challenge: `docs/AI_PROMPT.md`, `docs/ai-output.md`,
      `docs/keputusan-final.md` (tabel usulan-vs-keputusan + alasan).
- [x] `flutter analyze` bersih, `flutter test` hijau.

## Refleksi singkat

Lihat `docs/keputusan-final.md` — interface di domain agar test murni;
use case hanya saat ada aturan bisnis; over-engineering CRUD ditolak tertulis.
