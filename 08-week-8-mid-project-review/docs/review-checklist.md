# Review Checklist & Audit Kesiapan Tengah Semester (Week 8)

Dokumen ini memuat checklist audit branch, konvensi commit, peer code review, dan kesiapan arsitektural proyek tengah semester (*Mid-Project Review*).

---

## 1. Audit Branching Model & Riwayat Git

Berdasarkan audit riwayat git repositori (`git log --oneline -15`, `git branch -a`, `git status`):
- **Sebelumnya:** Mayoritas pengerjaan mingguan langsung di-commit ke branch `main`, sebagian pesan commit belum terstandardisasi (misalnya `week5`, `week4`, `2`).
- **Penerapan GitFlow Sekarang:**
  - Branch `main`: Selalu stabil, siap rilis, dan terlindungi.
  - Branch `develop`: Branch integrasi utama seluruh pengerjaan fitur mingguan.
  - Branch `feature/*`: Branch kerja berumur pendek (< 3 hari) untuk mengimplementasikan satu fitur terisolasi.
  - Branch `fix/*`: Perbaikan bug terarah disertai pengujian.

---

## 2. Simulasi Perbaikan Pesan Commit Buruk

Tabel rekonstruksi commit lama menjadi format [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): deskripsi`):

| # | Commit Lama (Hash) | Format Konvensional Baru | Alasan Perbaikan & Penjelasan |
|---|---|---|---|
| 1 | `8af722b` - `week5` | `feat(offline_notes): implementasi sqlite local db dan auto theme mode` | Pesan lama sangat ambigu dan tidak memberi konteks modul apa yang diubah. Format baru merinci bahwa fitur local database dan sinkronisasi offline diimplementasikan pada paket offline notes. |
| 2 | `1a245fa` - `week4` | `feat(api): integrasi rest api dio dan dynamic item list` | Pesan lama hanya menyebut nomor minggu. Format konvensional baru menjelaskan aksi penambahan fitur konsumsi API REST dengan library HTTP client Dio. |
| 3 | `b5aa77d` - `2` | `fix(layout): perbaiki overflow renderflex pada layar portrait` | Pesan lama berupa satu angka "2" tanpa arti teknis sama sekali. Format baru menegaskan scope masalah layout dan solusi perbaikan overflow. |

---

## 3. Checklist Kesiapan Tengah Semester (Mid-Project Readiness)

### A. Sterilitas Arsitektur & Aturan Dependensi (Clean Architecture)
- [x] **Layer Presentation Steril dari SQLite / Database Langsung**:
  - Pemeriksaan `grep "sqflite" lib/features/*/presentation/` menghasilkan **0 temuan**.
- [x] **Layer Presentation Steril dari SharedPreferences Langsung**:
  - Pemeriksaan `grep "shared_preferences" lib/features/*/presentation/` menghasilkan **0 temuan**.
- [x] **Layer Domain Bebas dari Framework Flutter/Platform (Pure Dart)**:
  - Pemeriksaan `grep "package:flutter" lib/features/*/domain/` menghasilkan **0 temuan**.
  - Entity, usecase, dan repository interface murni menggunakan Dart standar (`dart:core`, `dart:async`).

### B. Otomasi & Kualitas Kode (Mesin Hijau)
- [x] **Static Analysis Clean**:
  - Perintah `flutter analyze` berjalan dengan **0 errors, 0 warnings, 0 infos**.
- [x] **Code Formatter Terstandarisasi**:
  - Seluruh kode Dart telah diformat menggunakan `dart format .`.
  - Pengecekan otomatis CI `dart format --output=none --set-exit-if-changed .` lolos tanpa diff.
- [x] **Automated Testing Hijau**:
  - Seluruh unit tests, usecase tests, domain model tests, widget tests, dan golden tests lolos 100% (`21 passed`).

### C. Alur Kolaborasi Tim & Pull Request
- [x] **Branching Standard**: Branch `develop` aktif sebagai basis integrasi; fitur dikerjakan di `feat/notes-validation`.
- [x] **Pull Request Ringkas (< 300 baris)**: PR #12 menambahkan validasi form input catatan (+102/-19 baris).
- [x] **Template PR Lengkap**: Terdapat deskripsi Masalah, Solusi, Cara Pengujian, dan Screenshot pembuktian.
- [x] **Continuous Integration (CI)**: GitHub Actions workflow terpasang di `.github/workflows/ci.yml`.

---

## 4. Formulir Peer Code Review (Simulasi Sejawat)

| Komponen | Penilaian Peer Reviewer | Catatan & Evaluasi |
|---|---|---|
| **Kebenaran (Correctness)** | **Lolos** | Validasi string kosong (`trim().isEmpty`) mencegah penyimpanan catatan kosong di level UI dialog dan UseCase `AddNote`. |
| **Arsitektur (Architecture)** | **Lolos** | Validasi UI memakai `FormState` bawaan Flutter tanpa merusak abstraction domain; domain tetap memiliki validasi bisnis `ValidationFailure`. |
| **Pengujian (Tests)** | **Lolos** | Terdapat widget test `test/validate_note_test.dart` dan usecase test `test/add_note_test.dart`. |
| **Keterbacaan (Clean Code)** | **Lolos** | Penamaan variabel deskriptif, pemisahan widget terstruktur, dan error state tertangani. |
| **Keputusan Review** | **APPROVE** | Siap dimerge ke branch `develop`. |
