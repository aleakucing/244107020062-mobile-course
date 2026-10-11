# Keputusan final — usulan vs keputusan

| # | Usulan AI | Keputusan final | Alasan teknis |
|---|-----------|-----------------|---------------|
| 1 | Feature-first `features/{notes,settings}/{domain,data,presentation}` + `core/` | **Terima** | Satu fitur bisa dipahami/dihapus tanpa menyentuh fitur lain. Cocok untuk portofolio multi-minggu. |
| 2 | Use case per CRUD (`UpdateNote`, `DeleteNote`, `GetDarkMode`...) | **Tolak sebagian**. Hanya `GetNotes`, `AddNote`, `SyncNotes` jadi use case. Update/delete/settings langsung repository → notifier | Over-engineering untuk CRUD satu-baris pada tim kecil: +1 file +1 test per operasi tanpa aturan bisnis. Use case wajib saat ada validasi (judul kosong), gabungan >1 repository, atau aturan sync. Didokumentasikan di kode (`updateNote` comment). |
| 3 | Pisah datasource (`NotesLocalDataSource`, `PrefsDataSource`) | **Tolak (YAGNI)** | Project hanya 1 tabel + 2 key prefs. Lapisan tambahan menambah indireksi tanpa manfaat uji. Bila tabel >3 atau ada remote+local, datasource wajib diadakan. |
| 4 | GoRouter + redirect auth | **Tolak untuk Week 7** | App 2 tab tanpa deep-link/auth. `IndexedStack` + `routes.dart` konstanta cukup. GoRouter dicadangkan saat fitur auth/deep-link (Week 6) digabung. |
| 5 | `fpdart`/`dartz` `Either<Failure,T>` | **Tolak, pakai Dart record** | Record `({T data, Failure? failure})` bawaan Dart 3 eksplisit sukses/gagal tanpa dependensi baru, cukup untuk kontrak kecil. `fpdart` sepadan bila chaining/compose kompleks. |
| 6 | `get_it` untuk DI | **Tolak, Riverpod saja** | Riverpod `Provider` sudah mencakup DI + state + override test. Tambahan container DI menduplikasi mekanisme. |
| 7 | Mapping di entity (`toMap/fromMap` di `Note`) | **Tolak** | Melanggar separation of concerns: entity murni bisnis, model representasi luar. Mapping hanya di `NoteModel`. |

## Trade-off yang dinilai

- **Over-engineering cost:** tiap use case satu-baris ≈ +40 baris + test
  boilerplate. Untuk 6 CRUD → ~240 baris tanpa bug yang dicegah.
  Biaya sepadan saat logika tumbuh (validasi, sync, multi-repo).
- **Under-engineering risk:** tanpa interface repository, test domain
  butuh SQLite asli → lambat & flaky. Interface + record Failure
  membuat `test/get_notes_test.dart` murni (14/14 lolos tanpa DB).
- **Dependency rule:** panah `presentation → domain ← data`.
  `domain` tidak tahu Flutter/sqflite/shared_preferences → logika
  bisa di-unit-test murni. Dibuktikan 3 grep nol hasil.

## Refleksi (jawaban singkat)

- **Mengapa interface di domain, bukan data?**
  Agar domain mendefinisikan kebutuhan (DIP), data memenuhi.
  Bila dibalik, domain mengimpor data → test domain butuh SQLite,
  ganti DB memaksa ubah logika bisnis.
- **Kapan use case dibutuhkan vs repository langsung?**
  Butuh: validasi/aturan bisnis, gabungan >1 repo, operasi sync.
  Cukup langsung: CRUD satu-baris tanpa aturan (update/delete di sini).
- **Biaya over-engineering bagi tim kecil?**
  Waktu + kognitif + boilerplate tanpa nilai uji. Sepadan saat fitur
  kompleks / tim besar / kontrak antar-tim.
- **Bagian AI yang ditolak?** Lihat tabel #2–#6 di atas.
