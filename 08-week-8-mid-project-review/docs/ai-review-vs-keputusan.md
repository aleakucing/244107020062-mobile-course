# AI Review vs Keputusan Final Tim Pengembang

Dokumen ini mencatat interaksi peninjauan kode (*AI Code Review*), analisis validitas saran AI, dan pertimbangan teknis dalam memutuskan apakah usulan AI diterima, disesuaikan, atau ditolak.

---

## 1. Prompt Review AI yang Digunakan

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

---

## 2. Hasil Output Mentah AI Reviewer

AI menghasilkan 5 poin temuan sebagai berikut:

1. **Temuan 1 (Blocker - Correctness/UI)**: `showAddDialog` menggunakan `TextField` biasa dengan validasi imperatif `if (title.isEmpty) ScaffoldMessenger...`. Jika pengguna menekan Simpan berulang kali, SnackBar menumpuk dan dialog tidak menampilkan inline error helper.  
   *Saran AI:* Ubah menjadi `Form` + `TextFormField` dengan `validator` agar feedback muncul langsung di bawah field input.

2. **Temuan 2 (Saran - Test/Reliability)**: Pengujian unit `add_note_test.dart` hanya menguji validasi usecase pada string spasi `'   '`, namun belum ada pengujian level UI widget yang memverifikasi bahwa dialog benar-benar menampilkan pesan error jika tombol Simpan ditekan saat field kosong.  
   *Saran AI:* Tambahkan widget test dengan `WidgetTester` untuk memverifikasi interaksi dialog.

3. **Temuan 3 (Blocker - Architecture Violation)**: Disarankan memindahkan logika validasi string kosong langsung ke dalam SQLite trigger di database `db.dart` atau membuat decorator Dio HTTP interceptor untuk validasi form sebelum dikirim ke backend.  
   *Saran AI:* Tambahkan logic validasi di `lib/features/notes/data/local/db.dart` dengan SQL `CHECK(length(title) > 0)`.

4. **Temuan 4 (Saran - Architecture)**: `NoteNotifier.updateNote` langsung memanggil repository tanpa melalui use case terpisah `UpdateNote`.  
   *Saran AI:* Buat file `update_note.dart` yang membungkus call ke repository.

5. **Temuan 5 (Saran - Style/Nitpick)**: AI menyarankan penataan ulang whitespace dan indentation manual pada berkas `note_model.dart`.

---

## 3. Matriks Verifikasi: Usulan AI vs Keputusan Final

| No | Temuan AI | Level dari AI | Bukti & Analisis Pengembang | Keputusan Final | Alasan Keputusan Pengembang |
|---|---|---|---|---|---|
| **1** | Validasi input `showAddDialog` imperatif tanpa inline field error. | Blocker | Terbukti di `notes_page.dart`: `TextField` tidak menampilkan pesan error visual di form dialog. | **DITERIMA** | Mengganti `TextField` dengan `TextFormField` dan `FormState` memberikan UX standar Flutter yang responsif tanpa mengubah dependency layer. |
| **2** | Tidak ada pengujian UI dialog untuk validasi kosong. | Saran | Terbukti di folder `test/`: sebelumnya hanya ada `add_note_test.dart` (use case) dan `widget_test.dart` umum. | **DITERIMA** | Menambahkan `test/validate_note_test.dart` yang menguji `showAddDialog` memastikan regresi validasi tertangkap otomatis oleh pipeline CI. |
| **3** | Validasi dipindahkan ke SQLite trigger / Dio interceptor. | Blocker | **Cacat Arsitektur**. Mengikat aturan validasi input pada platform database SQLite merusak portabilitas dan melanggar prinsip Clean Architecture. | **DITOLAK** | Aturan bisnis telah diamankan di domain use case (`AddNote`), dan validasi tampilan berada di UI. Meletakkannya di trigger DB adalah tight-coupling yang tidak perlu dan mempersulit testing murni. |
| **4** | Pembuatan use case `UpdateNote` untuk CRUD 1 baris. | Saran | Analisis YAGNI: `updateNote` saat ini hanya operasi CRUD langsung tanpa transformasi atau business rules tambahan. | **DITOLAK** | Mengikuti keputusan arsitektural di Week 7: use case hanya dibuat saat ada logika bisnis nyata (seperti validasi di `AddNote` atau orkestrasi di `SyncNotes`). Menambahkan usecase 1-baris tanpa aturan bisnis hanya menambah boilerplate. |
| **5** | Penataan whitespace / indentation manual. | Saran | Style nitpick. Pemeriksaan style sudah ditangani otomatis oleh `dart format`. | **DITOLAK** | Hal terkait format diserahkan seutuhnya ke `dart format` dan CI GitHub Actions, bukan perdebatan manual antar manusia atau review AI. |

---

## 4. Kesimpulan Teknis

- **Penerimaan AI:** Rekomendasi UX form (`TextFormField`) dan penambahan automated test berhasil meningkatkan keandalan aplikasi.
- **Penolakan AI:** Usulan yang melanggar arsitektur (tight-coupling ke SQLite) dan usulan over-engineering yang melanggar prinsip YAGNI berhasil disaring secara kritis.
- **Prinsip Utama:** AI berfungsi sebagai alat bantu deteksi awal, namun integritas arsitektur dan keputusan rekayasa perangkat lunak tetap berada penuh di tangan engineer.
