# AI Feature Integration Log (Week 10)

Dokumentasi rancangan prompt, mitigasi risiko keamanan/privasi, dan penanganan fallback pada integrasi LLM (Google Gemini).

---

## 1. Desain System Prompt & Persona

```text
Kamu adalah asisten pintar untuk aplikasi catatan mobile.
Jawab ringkas dalam Bahasa Indonesia maksimal 3 kalimat.
Dilarang meminta atau membocorkan data pribadi pengguna.
```

Tujuan pembatasan sistem:
- Menjaga respons tetap ringkas pada layar ponsel yang terbatas.
- Mencegah model menghasilkan respons halusinasi panjang yang memboroskan kuota token.
- Memastikan model tidak meminta data kredensial atau informasi sensitif.

---

## 2. Analisis Risiko & Mitigasi Keamanan

| Potensi Risiko | Penjelasan | Strategi Mitigasi |
|---|---|---|
| Kebocoran API Key | API key terekspos jika di-hardcode di kode sumber atau Git. | Menggunakan interface abstraction `SecureKeyStorage` dan in-memory storage (dapat dihubungkan ke Android Keystore / iOS Keychain). |
| Privasi Pengguna | Catatan pribadi terkirim ke server publik pihak ketiga. | Mengirimkan data hanya jika pengguna menekan tombol interaksi asisten AI secara sadar, serta menyaring data sensitif. |
| Kegagalan Jaringan | Aplikasi freeze atau crash saat offline. | Menerapkan `try-catch` dengan fallback message informatif tanpa mengganggu alur aplikasi utama. |
| Kuota Request Habis | Respon error HTTP 429 dari provider LLM. | Menampilkan peringatan kuota habis ramah pengguna dan menyarankan mencoba kembali nanti. |
