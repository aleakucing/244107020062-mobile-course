# Laporan Praktikum Minggu 11: Optimasi Performa Aplikasi Mobile

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

---

## 1. Deskripsi Praktikum

Pada praktikum Minggu 11, dilakukan analisis profil performa (*profiling*) dan penerapan teknik optimasi pada aplikasi mobile Flutter. Tujuannya adalah menghilangkan *jank* (patah-patah saat scrolling), menghemat konsumsi memori, serta memastikan aplikasi berjalan mulus pada target 60 FPS (di bawah 16.67 ms per frame).

Tiga teknik utama yang diterapkan:
1. **Pengurangan Rebuild Tidak Perlu:** Memisahkan komponen UI menjadi widget tersendiri dan memanfaatkan `const` constructor.
2. **Isolasi Pengecatan Layar (*Repaint Boundary*):** Mengisolasi item list dengan `RepaintBoundary` agar perubahan pada satu item tidak memicu *repaint* pada seluruh layar.
3. **Pemuatan Bertahap (*Lazy Loading & Pagination*) serta Caching:** Menggunakan `ListView.builder` dengan mekanisme *infinite scroll* dan penyimpanan sementara data di memori untuk menghindari pengambilan data berulang.

---

## 2. Hasil Pengujian & Verifikasi

Semua pemeriksaan kualitas kode dan pengujian otomatis berjalan sukses:

- **Static Analysis (`flutter analyze`):** Bersih tanpa error atau peringatan (0 issues).
- **Pengujian Fungsional (`flutter test`):** 5 pengujian otomatis lulus, mencakup pengujian cache in-memory, isolasi `RepaintBoundary`, serta mekanisme *lazy loading* saat pengguna melakukan scroll.

---

## 3. Dokumentasi Tampilan Aplikasi & Profiling

| DevTools CPU Profiling (Sebelum) | DevTools CPU Profiling (Sesudah) |
| :---: | :---: |
| ![Before Profiling](screenshots/before-profile.png) | ![After Profiling](screenshots/after-profile.png) |
| *Frame drop terdeteksi (>32 ms)* | *Frame stabil di bawah 16 ms (60 FPS)* |

| DevTools Memory Snapshot | Tampilan Daftar Teroptimasi |
| :---: | :---: |
| ![Memory Profile](screenshots/memory-profile.png) | ![App Optimized](screenshots/app-optimized.png) |
| *Bebas dari kebocoran memori (leak-free)* | *Scroll halus dengan pemuatan halaman bertahap* |

---

## 4. Refleksi

- **Dampak Optimasi Paling Terasa:** Penggunaan `ListView.builder` dan `RepaintBoundary` memberikan dampak paling signifikan pada kelancaran scroll karena widget di luar layar tidak dibuat sebelum waktunya.
- **Pembersihan Resource:** Memastikan semua controller dan listener dilepas pada method `dispose()` adalah kunci menjaga memori tetap stabil dalam jangka panjang.
- **Optimasi Terukur:** Melakukan pengukuran dengan DevTools sebelum dan sesudah perubahan memastikan bahwa optimasi yang dilakukan benar-benar meningkatkan performa secara nyata.
