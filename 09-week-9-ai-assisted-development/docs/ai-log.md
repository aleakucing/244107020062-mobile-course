# AI Assisted Development Log (Week 9)

Dokumentasi interaksi AI coding assistant, verifikasi kode, dan keputusan rekayasa perangkat lunak untuk penambahan fitur pencarian catatan.

---

## 1. Formula Prompt 5 Slot

```text
Peran: Senior Flutter Developer
Konteks: Feature-first Clean Architecture (presentation -> domain <- data), Flutter Riverpod 3.x, SQLite offline-first (clean_notes project).
Tugas: Buat use case pencarian catatan (SearchNotes) dan integrasikan ke NotesPage dengan textfield pencarian dan empty state jika tidak ada catatan yang cocok.
Batas: Jangan ubah arsitektur, jangan panggil SQLite langsung dari widget, pertahankan pure Dart di layer domain, maksimal 80 baris.
Output: Kode usecase domain, provider Riverpod, integrasi UI NotesPage, dan unit/widget test.
```

---

## 2. Output Mentah AI & Analisis Temuan

AI memberikan usulan awal berupa:
1. Menambahkan fungsi filter di dalam widget `build()` langsung menggunakan `notes.where(...)`.
2. Menyimpan state query menggunakan `StateProvider<String>`.
3. Menggunakan method string `.contains(query)` tanpa konversi `.toLowerCase()` dan tanpa `.trim()`.

### Temuan Bug / Halusinasi AI:
- **Halusinasi 1 (API Riverpod Outdated):** AI menyarankan penggunaan `StateProvider<String>((ref) => '')`. Pada Riverpod versi 3.x, `StateProvider` sudah usang/dihapus dan harus digantikan oleh `NotifierProvider` dengan class `Notifier<String>`.
- **Halusinasi 2 (Pelanggaran Clean Architecture):** AI menyarankan filtering logika langsung di dalam `NotesPage` (Presentation layer) atau menyarankan query SQL `LIKE %query%` langsung di widget.
- **Bug Fungsional (Case Sensitivity):** Logika pencarian yang diusulkan bersifat case-sensitive (`note.title.contains(query)`). Pencarian kata "belanja" tidak akan menemukan catatan berjudul "Belanja mingguan".

---

## 3. Matriks Keputusan: Usulan AI vs Implementasi Nyata

| Usulan AI | Analisis & Bukti | Keputusan | Tindakan Pengembang |
|---|---|---|---|
| `StateProvider<String>` untuk search query | Kompilasi gagal pada Riverpod 3.x (`Method not found: 'StateProvider'`). | **Ditolak & Refactor** | Menggunakan `NotifierProvider<SearchQueryNotifier, String>` standar Riverpod modern. |
| Logika filter ditaruh di dalam Widget | Merusak arsitektur (logika bisnis tercampur di UI dan sulit diuji secara terisolasi). | **Ditolak & Refactor** | Dipindahkan ke UseCase murni `SearchNotes` di layer Domain (`domain/usecases/search_notes.dart`). |
| Pencarian tanpa `.toLowerCase()` & `.trim()` | Menghasilkan bug saat pengguna mengetik huruf kecil untuk judul berhuruf kapital. | **Ditolak & Diperbaiki** | Menambahkan `.trim().toLowerCase()` pada judul dan isi catatan. |
| Empty state UI saat hasil tidak ditemukan | Desain user experience responsif saat query tidak ada yang cocok. | **Diterima** | Diterapkan pada `NotesPage` dengan menampilkan ikon pencarian kosong dan pesan teks informatif. |
