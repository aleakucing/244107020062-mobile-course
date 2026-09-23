import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Reuse Dio terpusat (baseUrl JSONPlaceholder + timeout 10s + LogInterceptor).
import 'package:week4_api/data/api_client.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';

// Provider Dio khusus komentar: memakai createDio() yang sama dengan Post
// agar baseUrl & timeout konsisten. Dipisah agar mudah di-override di test.
final commentDioProvider = Provider<Dio>((ref) => createDio());

// Provider repository: satu instance CommentRepository per app.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(commentDioProvider)),
);

// Notifier per-postId: state = AsyncValue<List<Comment>>.
// - build() async melempar exception -> Riverpod mengubahnya jadi AsyncError
//   secara otomatis (penanganan error otomatis, tanpa try-catch manual).
// - Family dipakai karena tiap postId punya daftar komentar berbeda.
//   Pola Riverpod 3 non-generator: constructor menyimpan arg family,
//   build() tanpa arg membaca field tersebut.
class CommentListNotifier extends AsyncNotifier<List<Comment>> {
  // Constructor menerima postId dari family (diisi otomatis oleh
  // AsyncNotifierProvider.family saat ref.watch(commentListProvider(1))).
  CommentListNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    final repository = ref.watch(commentRepositoryProvider);
    return repository.fetchComments(postId);
  }

  // Refresh manual (pull-to-refresh / tombol coba lagi).
  // Pola sama dengan PostListNotifier.refresh(): set Loading, coba fetch,
  // sukses -> AsyncData, gagal -> AsyncError.
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(commentRepositoryProvider);
      state = AsyncData(await repository.fetchComments(postId));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// AsyncNotifierProvider keluarga postId + matikan retry otomatis Riverpod 3
// agar error langsung final dan mudah diuji (tanpa ini provider me-retry
// dan test menggantung / melakukan HTTP sungguhan berulang).
final commentListProvider = AsyncNotifierProvider.family<
    CommentListNotifier, List<Comment>, int>(
  CommentListNotifier.new,
  retry: (retryCount, error) => null,
);

// Fungsi pesan error ramah pengguna (Indonesia) untuk UI.
// Menangani 4 kasus wajib: timeout, connection error, 404, dan 500.
// Dipakai di widget: Text(commentErrorMessage(err)).
String commentErrorMessage(Object error) {
  // DioException adalah error jaringan standar dari Dio.
  if (error is DioException) {
    switch (error.type) {
      // Timeout: server/Internet lambat atau request >10 detik.
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
      // Connection error: tidak ada internet / DNS / server tidak terjangkau.
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa internet Anda.';
      // Bad response: server merespons dengan status error (404/500/dll).
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        // 404: endpoint/post tidak ditemukan.
        if (code == 404) return 'Data tidak ditemukan (404).';
        // 500: server JSONPlaceholder/internal error -> pesan khusus ramah.
        if (code == 500) return 'Server sedang gangguan (500). Coba lagi nanti.';
        // 500-an lain (502/503) masuk sini.
        if (code != null && code >= 500) {
          return 'Server bermasalah ($code). Coba lagi nanti.';
        }
        // 401/403: akses ditolak (untuk kelengkapan, di luar 4 wajib).
        if (code == 401 || code == 403) {
          return 'Akses ditolak ($code). Periksa kredensial Anda.';
        }
        return 'Server bermasalah ($code). Coba lagi nanti.';
      // Kasus Dio lain (cancel, unknown): pesan generik jaringan.
      default:
        return 'Terjadi kesalahan jaringan. Coba lagi.';
    }
  }
  // Timeout murni Dart (dari .timeout()) bukan DioException -> tangani khusus.
  if (error is TimeoutException) {
    return 'Koneksi lambat atau timeout. Periksa internet Anda lalu coba lagi.';
  }
  // Fallback error tak dikenal: tampilkan apa adanya agar bisa dilaporkan.
  return 'Terjadi kesalahan tak terduga: $error';
}
