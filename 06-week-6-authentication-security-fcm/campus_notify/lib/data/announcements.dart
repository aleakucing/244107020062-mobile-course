class Pengumuman {
  const Pengumuman(
      {required this.id,
      required this.judul,
      required this.isi,
      required this.tanggal});
  final String id;
  final String judul;
  final String isi;
  final String tanggal;
}

const daftarPengumuman = [
  Pengumuman(
      id: "1",
      judul: "Jadwal kuliah berubah",
      isi: "Kelas Mobile pindah ke Ruang A2 jam 13.00. Bawa laptop masing-masing.",
      tanggal: "3 Okt 2026"),
  Pengumuman(
      id: "2",
      judul: "Pengumpulan tugas mobile",
      isi: "Tugas week 6 dikumpul via repository sebelum Senin jam 23.59.",
      tanggal: "3 Okt 2026"),
  Pengumuman(
      id: "3",
      judul: "Kuliah tamu industri",
      isi: "Kuliah tamu praktisi Android di Aula Gedung TI jam 09.00.",
      tanggal: "3 Okt 2026"),
];

Pengumuman cariPengumuman(String id) {
  return daftarPengumuman.firstWhere((item) => item.id == id,
      orElse: () => const Pengumuman(
          id: "-", judul: "Tidak ditemukan", isi: "-", tanggal: "-"));
}
