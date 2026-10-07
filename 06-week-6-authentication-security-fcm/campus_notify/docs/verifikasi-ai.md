# Verifikasi AI - Week 6

Hasil cek draf AI satu per satu:

1. Background handler top-level dengan pragma entry point: Lolos. Ada di lib/messaging/push_service.dart sebagai fungsi top-level, bukan method kelas.

2. onTokenRefresh mengirim token baru ke backend: Lolos dengan catatan. initFcmToken menerima callback onToken dan main.dart meneruskannya ke POST /devices. Di mode mock tidak ada FCM asli, jadi pengiriman nyata menunggu perangkat + Firebase aktif.

3. Foreground memakai local notification manual: Lolos. listenForeground memanggil showPengumumanLocal karena sistem tidak menampilkan banner otomatis saat aplikasi terbuka.

4. Klik dari tiga state masuk rute benar: Lolos level kode. onMessageOpenedApp, getInitialMessage, dan payload dialog foreground semua lewat routeFromMessage yang diunit-test. Uji klik di perangkat ikut docs/matriks-uji.md.

5. Token dan secret tidak di-hardcode dan tidak di-log penuh: Lolos. Token hanya di secure storage. Layar debug memakai shortToken 12 karakter pertama + titik-titik. Refresh token hanya lewat body POST HTTPS.

6. Perbedaan Android 13+ vs iOS: Ditandai di komentar push_service.dart. Android 13+ wajib requestPermission runtime. iOS butuh konfigurasi APNs dan capability push di Xcode.

Keputusan final: pakai mock auth + JWT simulasi sesuai codelab. Titik pasang Firebase Auth sudah disiapkan di AuthRepository.login. Alasan: tanpa backend kampus, pola repository dan refresh token tetap identik sehingga migrasi hanya ganti sumber token.
