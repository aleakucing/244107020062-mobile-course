import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
// Import model yang BELUM ada -> test ini HARUS gagal (RED) sebelum implementasi.
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';

void main() {
  // Satu unit test wajib: fromJson dengan field yang hilang harus aman-null.
  test('Comment.fromJson aman null saat field hilang', () {
    // Arrange: JSON tidak lengkap (simulasi respons API tidak konsisten).
    // Hanya ada 'name', sisanya hilang.
    const json = <String, dynamic>{
      'name': 'Ibra',
    };

    // Act: parsing tidak boleh throw.
    final comment = Comment.fromJson(json);

    // Assert: field hilang diganti default yang aman.
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, 'Ibra');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Verifikasi error handling (wajib Minggu 4): pastikan tiap jenis error
  // dipetakan ke pesan ramah Indonesia, bukan stacktrace mentah.
  group('commentErrorMessage memetakan 4 error wajib', () {
    test('timeout -> pesan lambat/timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(commentErrorMessage(err), contains('timeout'));
    });

    test('connection error -> pesan tidak dapat terhubung', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.connectionError,
      );
      expect(commentErrorMessage(err), contains('terhubung'));
    });

    test('404 -> pesan tidak ditemukan', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 404,
        ),
      );
      expect(commentErrorMessage(err), contains('404'));
    });

    test('500 -> pesan gangguan server', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/comments'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/comments'),
          statusCode: 500,
        ),
      );
      expect(commentErrorMessage(err), contains('500'));
    });

    test('TimeoutException Dart murni -> pesan timeout', () {
      expect(
        commentErrorMessage(TimeoutException('lemot')),
        contains('timeout'),
      );
    });
  });

  // Verifikasi repository tanpa HTTP sungguhan: mock Dio via interceptor
  // yang langsung resolve data palsu, lalu pastikan parsing + query benar.
  test('fetchComments mem-parsing list dan mengirim postId', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'));
    String? capturedPath;
    Map<String, dynamic>? capturedQuery;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedPath = options.path;
          capturedQuery = Map<String, dynamic>.from(options.queryParameters);
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'postId': 1,
                  'id': 1,
                  'name': 'A',
                  'email': 'a@x.com',
                  'body': 'halo',
                },
                // Item rusak (bukan map) harus dibuang oleh whereType.
                'rusak',
                // Item dengan field hilang harus jadi default aman.
                {'name': 'parsial'},
              ],
            ),
          );
        },
      ),
    );

    final repo = CommentRepository(dio);
    final result = await repo.fetchComments(1);

    expect(capturedPath, '/comments');
    expect(capturedQuery?['postId'], 1);
    expect(result.length, 2);
    expect(result.first.email, 'a@x.com');
    expect(result.last.body, '');
  });
}
