import "package:dio/dio.dart";

String friendlyApiMessage(Object error) {
  if (error is DioException) {
    if (error.response?.statusCode == 401) {
      return "Sesi habis. Silakan login kembali.";
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Koneksi lambat atau timeout. Coba lagi.";
      case DioExceptionType.connectionError:
        return "Tidak dapat terhubung ke server. Periksa internet.";
      case DioExceptionType.badResponse:
        return "Server bermasalah (${error.response?.statusCode}). Coba lagi.";
      default:
        return "Terjadi kesalahan jaringan. Coba lagi.";
    }
  }
  return "Terjadi kesalahan tak terduga: $error";
}
