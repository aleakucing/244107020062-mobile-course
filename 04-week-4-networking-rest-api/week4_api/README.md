# Laporan Praktikum Minggu 4: Networking & REST API
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

## Praktikum 1: Fetch REST API dengan Dio + Riverpod

Mengambil 100 posts dari JSONPlaceholder (`GET /posts`) melalui `Dio` terpusat (`lib/data/api_client.dart`, timeout 10 detik) dan menampilkannya lewat `AsyncNotifierProvider` (`lib/data/providers.dart`). Saat internet normal, UI melewati fase loading (spinner) lalu me-render daftar.

### Tangkapan Layar Hasil Praktikum
| Daftar 100 Posts Berhasil Dimuat |
| :---: |
| ![Praktikum 1 Daftar Posts](screenshots/praktikum1_posts.png) |
| *ListTile berisi judul + body post dengan CircleAvatar ID; data dari `PostRepository.fetchPosts()`* |

---

## Praktikum 2: Error Handling Ramah + Retry

Dua skenario kegagalan diuji: (1) internet dimatikan (mode pesawat) lalu tekan refresh, dan (2) `baseUrl` sementara diganti URL salah. Keduanya dipetakan oleh `friendlyErrorMessage()` menjadi pesan Bahasa Indonesia beserta tombol **Coba lagi** (`ref.invalidate` / `refresh()`), bukan stacktrace mentah.

### Tangkapan Layar Hasil Praktikum
| Internet Mati (Mode Pesawat) + Refresh | `baseUrl` Salah (Simulasi Koneksi Gagal) |
| :---: | :---: |
| ![Praktikum 2 Offline](screenshots/praktikum2_offline.png) | ![Praktikum 2 BaseUrl Salah](screenshots/praktikum2_baseurl.png) |
| *Pesan "Tidak dapat terhubung ke server" + tombol Coba lagi; nyalakan internet lalu tekan Coba lagi* | *Pesan koneksi yang sama tampil; kembalikan `baseUrl` setelah uji* |

---

## Praktikum 3: Pagination Infinite Scroll

`home` di `main.dart` diganti menjadi `PagedPostPage`, yang memuat posts per halaman (`GET /posts?_page=&_limit=10` via `PostRepository.fetchPostsPage`). Scroll mendekati bawah memicu `loadNextPage()`: halaman 1 tampil dulu, indikator loading muncul di ujung list, data baru ditambahkan tanpa reload penuh.

### Tangkapan Layar Hasil Praktikum
| Pagination Berjalan (Data Bertambah Saat Scroll) |
| :---: |
| ![Praktikum 3 Paged](screenshots/praktikum3_paged.bmp) |
| *Halaman 1 tampil dulu, spinner bawah saat memuat halaman berikut, item menumpuk via `PagedPostsNotifier`* |

---

## AI Prompt Challenge

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error,
  404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

### Hasil AI Prompt Challenge
| Berkas Hasil | Peran |
| :--- | :--- |
| `lib/data/models/comment.dart` | Model `Comment` + `fromJson` aman-null (`as num? ?? 0`, `as String? ?? ''`) |
| `lib/data/repositories/comment_repository.dart` | `fetchComments(postId)` → `GET /comments?postId` + `.timeout(10 detik)` |
| `lib/data/comment_providers.dart` | `commentListProvider` (family per-`postId`) + `commentErrorMessage()` untuk 4 error wajib |
| `test/comment_test.dart` | 7 test: `fromJson` field hilang, 5 pemetaan error, 1 repository mock |

---

## Refactoring Challenge

### Poin-Poin Refactoring Kode
Dalam rangka meningkatkan kualitas dan keterbacaan kode (*clean code*), sejumlah refactoring dilakukan:
1. **Pemisahan Repository Layer (`PostRepository` / `CommentRepository`)**:
   - Logika network (`Dio.get`, query parameters, timeout) dipindah dari widget ke `lib/data/repositories/`.
   - Repository menerima `Dio` via constructor (dependency injection) sehingga mudah di-mock tanpa HTTP sungguhan.
2. **Pemisahan Provider Komentar (`comment_providers.dart`)**:
   - Provider Dio, repository, dan `AsyncNotifier` komentar dipindah ke berkas tersendiri agar `providers.dart` milik Post tidak tercemar.
   - Menggunakan pola Riverpod 3 non-generator: `extends AsyncNotifier` + constructor menyimpan arg family.
3. **Sentralisasi Pesan Error Ramah**:
   - `friendlyErrorMessage()` (Post) dan `commentErrorMessage()` (Comment, eksplisit 500) menerjemahkan `DioExceptionType` menjadi Bahasa Indonesia.
   - Menangani juga `TimeoutException` Dart murni dari `.timeout()`.
4. **Kepatuhan Standar Linter (`flutter analyze`)**:
   - Pengujian kode statis menghasilkan **No issues found!** (0 warnings).
   - Hasil eksekusi (08 Okt 2026):
   ```text
   Analyzing week4_api...
   No issues found! (ran in 9.2s)
   ```

---

## Pengujian Kode (Testing)

### Strategi Pengujian yang Diterapkan
Pengujian otomatis diterapkan pada dua tingkatan penting:
1. **Unit Testing Model (`test/comment_test.dart` → fromJson)**:
   - Menguji `Comment.fromJson` dengan field yang hilang agar menghasilkan default aman (`0` / `''`) tanpa throw.
   - Menguji `commentErrorMessage()` memetakan timeout, connection error, 404, 500, dan `TimeoutException` ke pesan ramah.
2. **Unit Testing Repository (mock Dio)**:
   - Memverifikasi `fetchComments(1)` mengirim path `/comments` + query `postId: 1` via interceptor mock.
   - Memastikan item rusak (bukan map) dibuang `whereType` dan item parsial jadi default aman.

Hasil pengujian: **7/7 test lolos** (`flutter test test/comment_test.dart` → **All tests passed!**).
Hasil eksekusi (08 Okt 2026):
```text
00:00 +0: Comment.fromJson aman null saat field hilang
00:00 +1: commentErrorMessage memetakan 4 error wajib timeout -> pesan lambat/timeout
00:00 +2: commentErrorMessage memetakan 4 error wajib connection error -> pesan tidak dapat terhubung
00:00 +3: commentErrorMessage memetakan 4 error wajib 404 -> pesan tidak ditemukan
00:00 +4: commentErrorMessage memetakan 4 error wajib 500 -> pesan gangguan server
00:00 +5: commentErrorMessage memetakan 4 error wajib TimeoutException Dart murni -> pesan timeout
00:00 +6: fetchComments mem-parsing list dan mengirim postId
00:00 +7: All tests passed!
```
Hasil `flutter test` penuh: **+11 -1** — satu-satunya yang gagal adalah `test/widget_test.dart: Counter increments smoke test`.
Catatan: `test/widget_test.dart` bawaan template (counter) gagal karena aplikasi kini menampilkan `PagedPostPage`, bukan counter — tidak terkait perubahan minggu ini.

---

## Checklist Verifikasi Praktikum

- [x] **Fetch REST API**: `GET /posts` via Dio tampil sebagai daftar 100 posts setelah loading.
- [x] **Error Handling Ramah**: Offline dan `baseUrl` salah menampilkan pesan Indonesia + tombol Coba lagi.
- [x] **Pagination**: `PagedPostPage` memuat per 10 item, indikator bawah, data menumpuk tanpa reload penuh.
- [x] **Repository Layer AI**: `Comment` aman-null, `fetchComments(postId)` + timeout 10 detik, provider family + 4 pesan error, unit test field hilang.
- [x] **Kualitas Kode**: Lolos `flutter analyze` dengan 0 peringatan dan `flutter test test/comment_test.dart` 7/7 lolos.
- [x] **Eksplorasi AI**: Hasil interaksi AI diverifikasi, disesuaikan, dan didokumentasikan dengan baik.

---

## Eksplorasi AI Prompt Challenge

Dokumentasi rinci menyatu dalam laporan ini (tidak ada berkas `docs/` terpisah pada minggu ini); kode hasil ada pada `lib/data/models/comment.dart`, `lib/data/repositories/comment_repository.dart`, `lib/data/comment_providers.dart`, dan `test/comment_test.dart`.

### Prompt yang Digunakan
```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error,
  404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

### AI Verification Checklist (Temuan & Analisis)

| No | Poin Pemeriksaan dari Instruktur | Hasil Evaluasi | Analisis Temuan & Tindakan Perbaikan |
| :-: | :--- | :-: | :--- |
| **1** | **Apakah `fromJson` aman null** (field hilang tidak crash)? | **Lolos** | Menggunakan `(json['x'] as num?)?.toInt() ?? 0` dan `json['x'] as String? ?? ''`, mengikuti pola `Post.fromJson`. Terbukti oleh test field hilang. |
| **2** | **Apakah `fetchComments(postId)` memakai query benar + timeout 10 detik?** | **Lolos** | Mengirim `queryParameters: {'postId': postId}` ke `/comments` dan membungkus dengan `.timeout(Duration(seconds: 10))`, di atas `connectTimeout`/`receiveTimeout` di `createDio()`. Terbukti oleh test mock Dio. |
| **3** | **Apakah error otomatis jadi `AsyncError` + 4 pesan ramah** (timeout, connection error, 404, 500)? | **Lolos** | `build()` async melempar exception → Riverpod menjadikannya `AsyncError` tanpa try-catch. `commentErrorMessage()` memetakan keempatnya (500 pesan khusus), plus `TimeoutException` Dart. Terbukti 5 test pemetaan. |
| **4** | **Apakah ada unit test `fromJson` field hilang?** | **Lolos** | `test('Comment.fromJson aman null saat field hilang')` — JSON hanya berisi `name`, sisanya default aman, tidak throw. |
| **5** | **Apakah kode AI memakai API Riverpod versi lama/keliru** (family salah, retry menggantung)? | **Diperbaiki** | Draf awal memakai `FamilyAsyncNotifier` yang tidak ada (`ref`/`state` undefined). Diperbaiki ke pola Riverpod 3 non-generator (`extends AsyncNotifier` + constructor arg + `AsyncNotifierProvider.family`) dan `retry: null` agar error final saat di-test. |
| **6** | **Jalankan `flutter analyze` dan `flutter test`, apakah hasil AI lolos tanpa warning?** | **Lolos** | `flutter analyze` → **No issues found!**; `flutter test test/comment_test.dart` → **7/7 All tests passed!** (widget_test bawaan gagal pre-existing, di luar cakupan). |

---

## Refleksi Pembelajaran

### 1. Mengapa repository layer dipisah dari UI/provider, dan apa untungnya saat testing?
> [!NOTE]
> **Prinsip Pemisahan Tanggung Jawab Network:**
> - **Repository (`CommentRepository`)** hanya tahu cara bicara ke server (path, query, timeout, parsing). **UI/provider** hanya tahu cara menampilkan `AsyncValue`.
> - Keuntungan testing: repository bisa diberi `Dio` mock via constructor, sehingga `fetchComments` diuji tanpa internet (seperti test interceptor di minggu ini). UI pun bisa diuji dengan override provider tanpa menyentuh HTTP.
> - Tanpa pemisahan, setiap perubahan endpoint memaksa edit widget, dan test selalu butuh server sungguhan (*flaky*).

---

### 2. Kapan timeout 10 detik penting, dan apa bedanya `connectTimeout`/`receiveTimeout` vs `.timeout()`?
- **Penting saat** sinyal lemah, server lambat, atau DNS menggantung — tanpa timeout, `await` tidak pernah kembali dan UI macet di spinner selamanya.
- **`connectTimeout`/`receiveTimeout` (di `createDio()`)**: batas per-fase koneksi di level Dio (jabat tangan TCP, jeda antar-byte respons).
- **`.timeout(Duration(seconds: 10))` (di `fetchComments`)**: batas total operasi di level Dart, menangkap juga kasus di luar klasifikasi Dio (maka ditangani sebagai `TimeoutException` di `commentErrorMessage`).
- Praktik minggu ini memakai keduanya: Dio sebagai jaring pengaman umum, `.timeout()` sebagai pemenuhan syarat eksplisit per-method.

---

### 3. Fetch 100 posts sekaligus vs pagination 10 per halaman — kapan masing-masing tepat?
- **Fetch sekaligus (`fetchPosts`)**: cocok untuk dataset kecil/stabil yang butuh pencarian/sort lokal instan (100 posts JSONPlaceholder masih ringan). Kekurangan: TTFB besar, memori menampung semua, tidak skalabel.
- **Pagination (`fetchPostsPage` + infinite scroll)**: wajib saat data besar/tumbuh (feed, katalog). Kelebihan: halaman 1 cepat tampil, memori bertahap, sinyal jelek tetap lihat data awal. Kekurangan: logika lebih kompleks (page tracker, `hasMore`, cegah double-fetch via `isLoadingMore`).
- Minggu ini membuktikan keduanya: daftar penuh untuk kesederhanaan, `PagedPostPage` untuk pengalaman produksi.

---

### 4. Bagian mana dari kode rekomendasi AI yang Anda perbaiki, dan mengapa perbaikan tersebut penting?
1. **Perbaikan API Family Riverpod:**  
   Draf AI memakai `FamilyAsyncNotifier` (pola generator) pada proyek non-generator sehingga `ref`/`state` undefined dan test gagal compile. Diperbaiki ke `extends AsyncNotifier` + constructor `this.postId` + `AsyncNotifierProvider.family`. Penting karena tanpa ini tidak ada satu pun kode komentar yang bisa berjalan.
2. **Penonaktifan Retry Otomatis:**  
   AI tidak menyetel `retry`, sehingga Riverpod 3 me-retry diam-diam saat error — test menggantung dan menghantam HTTP berulang. Ditambah `retry: (retryCount, error) => null` mengikuti pola `postListProvider`. Penting untuk error yang final dan test deterministik.
3. **Pesan 500 Eksplisit + `TimeoutException`:**  
   Draf awal hanya generik "server bermasalah" dan lupa `TimeoutException` Dart dari `.timeout()`. Ditambah cabang `code == 500` ("Server sedang gangguan (500)") dan cabang `TimeoutException`. Penting agar keempat error wajib terpetakan ke pesan ramah, bukan stacktrace.
4. **Verifikasi TDD Merah-Hijau:**  
   Test ditulis dulu dan disaksikan gagal (file model belum ada), baru implementasi minimal hingga hijau. Penting agar test terbukti benar-benar menguji perilaku, bukan sekadar lolos karena mengikuti kode yang sudah jadi.
