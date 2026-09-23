import 'package:dio/dio.dart';
import '../models/comment.dart';

// Repository layer untuk endpoint GET /comments?postId={id}.
// Tugas: memisahkan logika network (Dio) dari UI/provider,
// sehingga mudah di-mock saat testing dan konsisten dengan PostRepository.
class CommentRepository {
  // Terima Dio dari luar (dependency injection) agar bisa diganti
  // Dio palsu saat unit test tanpa HTTP sungguhan.
  CommentRepository(this._dio);
  final Dio _dio;

  // Ambil daftar komentar milik satu post.
  // - [postId]: id post dari JSONPlaceholder (1..100).
  // - Timeout 10 detik sesuai requirement: .timeout() membungkus
  //   request agar tidak menggantung saat server lambat/mati.
  // - DioException (timeout/connection/404/500) TIDAK di-catch di sini,
  //   melainkan diteruskan ke AsyncNotifier -> menjadi AsyncError otomatis.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio
        // Query ?postId={id} difilter oleh server JSONPlaceholder.
        .get<List>(
          '/comments',
          queryParameters: {'postId': postId},
        )
        // Timeout eksplisit 10 detik (selain connectTimeout/receiveTimeout
        // di createDio) agar syarat tugas terpenuhi di level method.
        .timeout(const Duration(seconds: 10));

    // response.data bisa null (mis. body kosong) -> fallback list kosong.
    final data = response.data ?? [];

    // whereType<Map<String, dynamic>> membuang item rusak (bukan map),
    // lalu map ke Comment.fromJson yang aman-null.
    return data.whereType<Map<String, dynamic>>().map(Comment.fromJson).toList();
  }
}
