# Matriks Uji Tiga App State - Week 6

Payload uji yang sama untuk semua state:

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Jadwal kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

| State | Yang diharapkan | Cara uji | Status |
|---|---|---|---|
| Foreground | Banner lokal muncul, klik masuk ke /pengumuman/3 | Aplikasi terbuka, kirim dari console atau backend | Logika teruji unit + widget. Uji perangkat ikut langkah ini |
| Background | Banner sistem muncul, klik masuk ke rute benar | Tekan Home, kirim, klik banner | Handler onMessageOpenedApp siap. Uji perangkat ikut langkah ini |
| Terminated | Aplikasi terbuka ke rute benar via getInitialMessage | Tutup aplikasi penuh, kirim, klik banner | Handler handleTerminated siap. Uji perangkat ikut langkah ini |

Catatan: uji perangkat butuh google-services.json aktif dan HP fisik atau emulator dengan Play Store. Selama itu belum ada, bukti perilaku berupa test hijau + screenshot UI di README.
