# Laporan Temuan Profiling Performa (Week 11)

Dokumentasi identifikasi bottleneck performa awal sebelum optimasi menggunakan Flutter DevTools.

---

## 1. Baseline Metrics (Sebelum Optimasi)

- **Frame Time Rata-rata:** 34.2 ms (melebihi batas aman 16.67 ms).
- **Kondisi:** Sering terjadi jank / frame drop merah saat scrolling cepat.
- **Konsumsi Memori:** Terjadi penumpukan instance controller yang belum dibersihkan.

---

## 2. Tiga Masalah Utama yang Ditemukan

1. **Unnecessary Widget Rebuild:**
   - Seluruh elemen list di-rebuild saat parent mengalami pembaruan state karena tidak menggunakan `const` constructor dan belum memisahkan komponen ke widget tersendiri.
2. **Repaint Berlebih Saat Scroll:**
   - Seluruh layer kanvas di-repaint secara berulang tanpa pembatas isolasi render.
3. **Pemuatan Data Tanpa Caching & Pagination:**
   - Pemuatan seluruh data sekaligus membebani memori dan jaringan, menyebabkan lag saat pengguna melakukan scroll cepat.
