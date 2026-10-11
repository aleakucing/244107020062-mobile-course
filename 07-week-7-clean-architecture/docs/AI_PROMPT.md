# AI Prompt Challenge — Week 7 Clean Architecture

Prompt yang dipakai (dari codelab):

```
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

Project aktual yang direfactor: `week5_offline_notes`
(auth tidak ada di Week 5, jadi analoginya: fitur `notes` + `settings`).
Struktur lama: `lib/{data, pages}` + `main.dart`.
Hasil analisis AI disimulasikan pada `ai-output.md`, keputusan final di
`keputusan-final.md`.
