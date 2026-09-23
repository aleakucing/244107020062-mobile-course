// Model untuk satu komentar dari JSONPlaceholder.
// Endpoint: GET https://jsonplaceholder.typicode.com/comments?postId={id}
// Setiap bagian dijelaskan dalam komentar sesuai syarat AI Prompt Challenge.
class Comment {
  // Konstruktor const + required: semua field wajib diisi saat membuat objek,
  // sehingga tidak ada Comment dengan field null di lapisan UI/provider.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // ID post induk (query ?postId={id}). int karena JSONPlaceholder selalu angka.
  final int postId;
  // ID unik komentar.
  final int id;
  // Judul/nama komentator.
  final String name;
  // Email komentator.
  final String email;
  // Isi komentar.
  final String body;

  // Factory fromJson yang AMAN NULL:
  // - (json['x'] as num?)?.toInt() ?? 0 : jika hilang/null/bukan angka -> 0.
  // - json['x'] as String? ?? '' : jika hilang/null -> string kosong.
  // Pola ini mencegah crash saat API mengirim field tidak lengkap.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: (json['postId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  // toJson untuk debugging/logging atau kebutuhan kirim data balik.
  // Tidak dipakai untuk GET, tapi melengkapi model agar simetris.
  Map<String, dynamic> toJson() => {
        'postId': postId,
        'id': id,
        'name': name,
        'email': email,
        'body': body,
      };
}
