# Laporan Praktikum Minggu 7: Clean Architecture

> **Mata Kuliah:** Pemrograman Mobile | **Semester:** Genap 2025/2026

---

### Identitas Mahasiswa

| Data | Keterangan |
| :--- | :--- |
| **Nama Lengkap** | Muchammad Ibrahim Al Amin |
| **NIM** | 244107020062 |
| **Kelas** | TI-3F |
| **Program Studi** | D-IV Teknik Informatika |
| **Jurusan** | Teknologi Informasi |
| **Institusi** | Politeknik Negeri Malang |

Proyek: `clean_notes` — refactor `week5_offline_notes` (Week 5) menjadi
Clean Architecture feature-first. Bukan project baru: kode yang sudah jalan
dipindah dan dipisah layer-nya, behavior UI identik.

---

## Tujuan Praktikum

- Menjelaskan SOLID + separation of concerns dengan contoh Flutter nyata.
- Membedakan feature-first vs layer-first beserta trade-off-nya.
- Menerapkan 3 layer (presentation/domain/data) + dependency rule.
- Membedakan entity vs model, peran repository/use case/DI.
- Menguji use case dengan repository palsu (tanpa DB/jaringan).

---

## Fitur Utama

- CRUD catatan offline-first (SQLite, `ORDER BY updated_at DESC`, flag `dirty`).
- Badge sinkron + tombol sync simulasi (delay 1 dtk + `markAllSynced`).
- Tema gelap/terang + terakhir dibuka (SharedPreferences via repository).
- Failure ramah pengguna: exception mentah → `Failure.message` sebelum UI.

---

## Arsitektur Layer dan Arah Dependensi

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

---

## Praktikum 1: Audit Kode Week 5 dan Pemetaan ke Layer

Kode Week 5 dipetakan dulu sebelum dipindah. Tujuannya agar refactor tidak
menjadi "menyalin folder", tetapi benar-benar memisahkan tanggung jawab.

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

Bukti dependency rule ada di `docs/verifikasi-grep.txt`: dua grep utama
(presentation steril dan domain steril) sama-sama menghasilkan **NOL**.

---

## Praktikum 2: Domain Layer — Entity, Repository Interface, Use Case

Domain adalah inti aplikasi dan tidak boleh bergantung pada framework.

- `Note` (`domain/entities/note.dart`) adalah entity murni: hanya field bisnis
  (`id`, `title`, `body`, `updatedAt`, `dirty`), tanpa `toMap`/`fromMap`.
- `NoteRepository` (`domain/repositories/note_repository.dart`) adalah
  **interface** yang mendefinisikan kebutuhan domain. Implementasinya ada di
  layer data, sehingga arah dependensi mengikuti Dependency Inversion Principle.
- `AddNote` memvalidasi judul kosong sebelum menyentuh repository.
  `GetNotes` membaca daftar catatan. `SyncNotes` menjalankan aturan sync.
- `updateNote`/`deleteNote` sengaja langsung ke repository dari notifier karena
  hanya CRUD satu baris tanpa aturan bisnis. Keputusan ini didokumentasikan di
  `docs/keputusan-final.md` agar tidak menjadi over-engineering.

Kontrak domain memakai Dart record, bukan `Either` dari package tambahan:

```dart
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  });
  // ...
}
```

Dengan pola ini, `test/get_notes_test.dart` dan `test/add_note_test.dart` bisa
menguji use case memakai repository palsu — tanpa SQLite, emulator, atau internet.

---

## Praktikum 3: Data Layer — Model, Repository Implementation, SQLite

Layer data adalah tempat semua detail eksternal: SQLite, SharedPreferences,
dan konversi data.

- `NoteModel` (`data/models/note_model.dart`) adalah representasi tabel.
  Mapping `toMap`/`fromMap`/`toEntity`/`fromEntity` **hanya** ada di sini.
- `NoteRepositoryImpl` mengimplementasikan `NoteRepository`, menjalankan query
  SQLite, lalu mengubah setiap exception menjadi `LocalFailure`. UI tidak pernah
  menerima exception mentah.
- `NoteRepositoryImpl({openDb})` menyuntikkan fungsi pembuka database. Di test,
  fungsi ini bisa diganti fake in-memory; di aplikasi asli memakai `openNotesDb`.
- `db.dart` membuat tabel `notes` + `cached_posts`, plus indeks
  `idx_notes_updated` pada `updated_at DESC` (versi database 2).
- `SettingsRepositoryImpl` menyimpan tema dan waktu terakhir dibuka di
  SharedPreferences, juga dengan failure yang ramah.

Skema utama:

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated ON notes(updated_at DESC);
```

### Tangkapan Layar Hasil Praktikum

| Sebelum Sync (2 Belum Tersinkron) | Sesudah Sync (Sinkron) |
| :---: | :---: |
| ![Sebelum sinkronisasi](./screenshots/05-dirty-sebelum.png) | ![Sesudah sinkronisasi](./screenshots/06-dirty-sesudah.png) |
| *Chip "2 belum tersinkron" dan ikon awan-off di tiap baris; diambil saat mode pesawat* | *Chip "sinkron", ikon awan-centang, dan SnackBar "Sinkron selesai (simulasi)"* |

Kedua tampilan membuktikan flag `dirty` tersimpan di SQLite dan berubah setelah
`SyncNotes` menjalankan `markAllSynced()`.

---

## Praktikum 4: Presentation Layer dan Dependency Injection

Presentation hanya mengurus tampilan dan state. Semua akses data lewat provider.

- `notes_providers.dart` adalah satu-satunya tempat wiring:
  `noteRepositoryProvider`, `getNotesProvider`, `addNoteProvider`,
  `syncNotesProvider`, `NotesNotifier`, dan `dirtyCountProvider`.
- `settings_providers.dart` melakukan hal yang sama untuk `SettingsRepository`
  dan `DarkModeNotifier`.
- `NotesPage` dan `SettingsPage` hanya memakai `ref.watch`/`ref.read`.
  Tidak ada SQL, Dio, JSON, `SharedPreferences.getInstance`, atau `DateFormat`
  di dalam widget.
- Formatting tanggal dan pesan error dipindah ke `lib/core/format.dart`
  sebagai fungsi murni yang mudah diuji.
- `main.dart` memakai `ProviderScope` + `HomeShell` dengan dua tab
  (`IndexedStack`), tanpa menambah GoRouter karena belum ada kebutuhan auth/deep-link.

### Tangkapan Layar Hasil Praktikum

Screenshot diambil langsung dari HP fisik **Infinix X6739 (Android 14)** melalui
`adb` pada resolusi portrait **1080x2400**, bukan golden test dan bukan
screenshot jendela desktop. Aplikasi yang dipakai adalah build release
(`flutter build apk --release`) dengan SQLite/SharedPreferences asli; dua
catatan dibuat lewat UI, lalu diuji sebelum dan sesudah sync. Golden test tetap
tersedia di `test/goldens/` untuk regresi visual.

| Daftar Catatan + Badge Dirty | Dialog Tambah Catatan |
| :---: | :---: |
| ![Daftar catatan dan badge dirty](./screenshots/01-notes-list.png) | ![Dialog tambah catatan](./screenshots/02-dialog-tambah.png) |
| *2 catatan urut `updated_at` DESC, chip "2 belum tersinkron", FAB, dan navigasi bawah* | *Dialog "Catatan baru": Judul + Isi + Batal/Simpan; judul kosong ditolak* |

| Pengaturan Tema Terang | Pengaturan Tema Gelap |
| :---: | :---: |
| ![Pengaturan tema terang](./screenshots/03-settings-terang.png) | ![Pengaturan tema gelap](./screenshots/04-settings-gelap.png) |
| *Toggle mati, tema terang; "Terakhir dibuka" tersimpan di SharedPreferences* | *Toggle menyala, seluruh layar bertema gelap; preferensi tetap tersimpan* |

Keterangan file dan cara regenerasi ada di `screenshots/README.md`.

---

## Stack

Flutter + `flutter_riverpod`, `sqflite`, `shared_preferences`, `path`.
Tanpa `get_it`/`fpdart`/GoRouter/Firebase — alasan di `docs/keputusan-final.md`.

---

## AI Prompt Challenge

Prompt yang dipakai:

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

Project aktual yang direfactor adalah `week5_offline_notes` (auth belum ada di
Week 5), sehingga analoginya menjadi fitur `notes` + `settings`. Output AI
direkonstruksi dan diverifikasi baris-per-baris, bukan disalin mentah.

### Usulan AI vs Keputusan Final

| # | Usulan AI | Keputusan | Alasan teknis |
| :---: | :--- | :--- | :--- |
| 1 | Feature-first `features/{notes,settings}/{domain,data,presentation}` + `core/` | **Terima** | Satu fitur bisa dipahami/dihapus tanpa menyentuh fitur lain. |
| 2 | Use case per CRUD (`UpdateNote`, `DeleteNote`, `GetDarkMode`, ...) | **Tolak sebagian** | Hanya `GetNotes`, `AddNote`, `SyncNotes` yang punya aturan bisnis. Update/delete satu baris langsung repository → notifier. |
| 3 | Pisah datasource (`NotesLocalDataSource`, `PrefsDataSource`) | **Tolak (YAGNI)** | Project hanya 1 tabel + 2 key prefs; lapisan tambahan hanya menambah indireksi. |
| 4 | GoRouter + redirect auth | **Tolak untuk Week 7** | Aplikasi hanya 2 tab tanpa auth/deep-link; `IndexedStack` + `routes.dart` cukup. |
| 5 | `fpdart`/`dartz` `Either<Failure, T>` | **Tolak, pakai Dart record** | Record `({T data, Failure? failure})` eksplisit sukses/gagal tanpa dependensi baru. |
| 6 | `get_it` untuk DI | **Tolak, Riverpod saja** | Riverpod `Provider` sudah mencakup DI, state, dan override test. |
| 7 | Mapping di entity (`toMap/fromMap` di `Note`) | **Tolak** | Melanggar separation of concerns; mapping hanya di `NoteModel`. |

Prompt asli: `docs/AI_PROMPT.md`; ringkasan output: `docs/ai-output.md`;
keputusan lengkap: `docs/keputusan-final.md`.

---

## Refactoring Challenge

### Poin-Poin Refactoring Kode

1. **Feature-first**: kode dipindah ke `lib/features/{notes,settings}/{domain,data,presentation}`
   dan utilitas murni ke `lib/core/`.
2. **Kontrak dan implementasi dipisah**: `NoteRepository`/`SettingsRepository`
   berada di domain, implementasinya di data.
3. **Entity vs model**: `Note` tetap murni; seluruh mapping SQLite ada di
   `NoteModel`.
4. **Use case selektif**: `GetNotes`, `AddNote` (validasi judul), dan `SyncNotes`
   (aturan sync) menjadi use case. Update/delete tidak dipaksa menjadi use case.
5. **Failure sebagai nilai balik**: repository menangkap exception dan
   mengembalikan `LocalFailure`; UI hanya menerima pesan yang ramah.
6. **DI terpusat**: hanya provider yang membuat implementasi repository;
   widget tidak pernah `new NoteRepositoryImpl()`.
7. **Database bisa di-inject**: `NoteRepositoryImpl({openDb})` memungkinkan test
   memakai fake in-memory tanpa SQLite asli.
8. **Presentation steril**: tidak ada SQL/Dio/JSON/SharedPreferences/DateFormat
   di halaman; formatting dipindah ke `lib/core/format.dart`.
9. **Entrypoint screenshot**: `lib/screenshot_main.dart` meng-override repository
   dengan data seed untuk preview web/golden; `test/screenshot_test.dart`
   menyimpan 6 golden regresi di `test/goldens/`. Gambar laporan di
   `screenshots/01..06` diambil dari HP fisik (release build, 1080x2400).
10. **Linter bersih**: `flutter analyze` → **No issues found!**

---

## Pengujian Kode (Testing)

1. **Unit use case (`test/get_notes_test.dart`, 2 test)**: `GetNotes` meneruskan
   daftar dari repository dan meneruskan failure tanpa melempar exception.
2. **Unit use case (`test/add_note_test.dart`, 5 test)**: validasi judul kosong,
   sukses dengan `dirty=true`, failure repository, serta `SyncNotes` sukses/gagal.
3. **Unit model + fungsi murni (`test/note_model_test.dart`, 5 test)**:
   roundtrip `toMap`/`fromMap`, aman terhadap field hilang, format tanggal,
   format "terakhir dibuka", dan pesan error lokal.
4. **Widget (`test/widget_test.dart`, 2 test)**: daftar dari provider dan
   empty state.
5. **Golden screenshot (`test/screenshot_test.dart`, 6 test)**: daftar catatan,
   dialog tambah, pengaturan terang/gelap, serta badge sebelum/sesudah sync.

Hasil: **20/20 test lolos**.

```text
00:05 +20: All tests passed!
```

Hasil `flutter analyze`:

```text
Analyzing 07-week-7-clean-architecture...
No issues found! (ran in 5.8s)
```

---

## Eksplorasi AI Prompt Challenge

Dokumentasi rinci ada di `docs/ai-output.md` dan `docs/keputusan-final.md`.

### AI Verification Checklist

| No | Poin Pemeriksaan | Hasil | Temuan dan Tindakan |
| :-: | :--- | :--- | :--- |
| 1 | Interface repository di domain, implementasi di data | **Lolos** | `NoteRepository`/`SettingsRepository` di domain; `*_repository_impl.dart` di data. |
| 2 | Domain bebas import Flutter/Dio/SQLite/Firebase | **Lolos** | Grep pada `domain` + `core` → NOL hasil; entity/use case murni Dart. |
| 3 | AI membuat use case untuk tiap CRUD satu-baris | **Ditolak sebagian** | Hanya `GetNotes`, `AddNote`, `SyncNotes`; sisanya langsung repository dengan alasan tertulis. |
| 4 | Entity bebas mapping | **Lolos** | `toMap`/`fromMap` hanya ada di `NoteModel`; `Note` murni. |
| 5 | Wiring DI terpusat, widget tidak membuat repository | **Lolos** | Hanya `notes_providers.dart` dan `settings_providers.dart` yang membuat implementasi. |
| 6 | Presentation steril dari akses data mentah | **Lolos** | Grep SQL/Dio/JSON/SharedPreferences di `presentation` → NOL hasil. |
| 7 | `flutter analyze` dan `flutter test` | **Lolos** | `No issues found!`; 20/20 **All tests passed!** |

---

## Refleksi Pembelajaran

### 1. Mengapa interface repository diletakkan di domain, bukan di data?

Karena domain adalah pemilik kebutuhan bisnis. Interface di domain membuat
domain mendefinisikan kontraknya sendiri (Dependency Inversion Principle),
sedangkan layer data berkewajiban memenuhinya. Bila dibalik, domain akan
mengimpor implementasi data, sehingga unit test domain membutuhkan SQLite dan
pergantian database memaksa logika bisnis ikut berubah.

### 2. Kapan use case dibutuhkan, dan kapan repository langsung cukup?

Use case dibutuhkan saat ada aturan bisnis (validasi judul pada `AddNote`),
operasi yang menggabungkan beberapa repository, atau aturan sync (`SyncNotes`).
Untuk CRUD satu baris tanpa aturan tambahan, seperti update dan delete di
project ini, memanggil repository langsung dari notifier lebih sederhana dan
tidak menambah boilerplate.

### 3. Apa biaya over-engineering bagi tim kecil?

Setiap use case satu baris menambah sekitar 40 baris kode plus test. Untuk enam
operasi CRUD, biayanya bisa mencapai ~240 baris tanpa bug yang benar-benar
dicegah. Bagi tim kecil, biaya kognitif dan waktu review ini lebih besar dari
manfaatnya. Use case baru sepadan ketika logika tumbuh kompleks, jumlah
repository bertambah, atau ada kontrak antar-tim.

### 4. Bagian mana dari hasil AI yang ditolak atau diperbaiki, dan mengapa?

1. **Use case per CRUD** ditolak karena over-engineering untuk operasi satu baris.
2. **Datasource terpisah** ditolak karena project hanya punya satu tabel dan dua
   key preferensi (YAGNI).
3. **GoRouter, `fpdart`, dan `get_it`** ditolak karena kebutuhan aplikasi masih
   sederhana; `IndexedStack`, Dart record, dan Riverpod sudah cukup.
4. **Mapping di entity** ditolak karena mencampur entity bisnis dengan detail
   penyimpanan; mapping dipindah ke `NoteModel`.
5. **Exception mentah ke UI** diperbaiki menjadi `Failure` yang ramah dan
   diuji lewat repository palsu.

---

## Cara Menjalankan Aplikasi

1. Arahkan terminal ke folder proyek:
   ```bash
   cd 07-week-7-clean-architecture
   ```
2. Pasang dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan di HP/emulator (disarankan untuk SQLite/SharedPreferences):
   ```bash
   flutter run
   ```
4. Verifikasi kualitas kode:
   ```bash
   flutter analyze
   flutter test
   ```
5. Untuk preview UI tanpa SQLite (Chrome/Windows) atau regresi golden:
   ```bash
   flutter run -t lib/screenshot_main.dart
   flutter test test/screenshot_test.dart --update-goldens
   ```
   Hasil golden ada di `test/goldens/` dan **tidak** dipakai sebagai gambar
   laporan. Untuk memperbarui screenshot laporan dari HP:
   ```bash
   flutter build apk --release
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
   lalu ulangi alur 6 layar di `screenshots/README.md`.

---

## Checklist Verifikasi Praktikum

- [x] 2 fitur penuh (`notes` + `settings`) terpisah domain/data/presentation.
- [x] Dependency rule terbukti — lihat `docs/verifikasi-grep.txt` (2 grep NOL).
- [x] Behavior identik — `screenshots/` before/after + uji manual.
- [x] 20 test lulus (syarat minimal 2: `test/get_notes_test.dart` sukses + failure).
- [x] 6 screenshot HP fisik 1080x2400 (`screenshots/01..06`); golden regresi
      tetap tersedia di `test/goldens/`.
- [x] AI Challenge: `docs/AI_PROMPT.md`, `docs/ai-output.md`,
      `docs/keputusan-final.md` (tabel usulan-vs-keputusan + alasan).
- [x] `flutter analyze` bersih, `flutter test` hijau (20/20).

---

## Dokumentasi Pendukung

- `docs/AI_PROMPT.md` — prompt asli AI Challenge.
- `docs/ai-output.md` — ringkasan output AI + checklist verifikasi.
- `docs/keputusan-final.md` — tabel usulan-vs-keputusan dan trade-off.
- `docs/verifikasi-grep.txt` — bukti dependency rule + hasil test.
- `screenshots/README.md` — keterangan keenam screenshot.
