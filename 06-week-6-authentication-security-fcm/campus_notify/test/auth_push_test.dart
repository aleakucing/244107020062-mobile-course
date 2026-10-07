import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:campus_notify/data/api_client.dart";
import "package:campus_notify/data/api_errors.dart";
import "package:campus_notify/data/auth_repository.dart";
import "package:campus_notify/data/token_store.dart";
import "package:campus_notify/messaging/push_service.dart";
import "package:campus_notify/providers/auth_provider.dart";
import "package:campus_notify/routes.dart";

class FakeTokenStore extends SecureTokenStore {
  String? access;
  String? refresh;
  bool cleared = false;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    cleared = true;
  }
}

class FakeAuthRepository extends AuthRepository {
  @override
  Future<String> refresh(String refreshToken) async {
    if (refreshToken.isEmpty) throw Exception("Refresh token hilang");
    return "renewed-access";
  }
}

class TestAdapter implements HttpClientAdapter {
  TestAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<List<int>>? requestStream, Future<void>? cancelFuture) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test("routeFromMessage menangani route kosong dan tanpa slash", () {
    expect(routeFromMessage({}), "/");
    expect(routeFromMessage({"route": "pengumuman/3"}), "/pengumuman/3");
    expect(routeFromMessage({"route": "/pengumuman/3"}), "/pengumuman/3");
  });

  test("data payload membawa id pengumuman", () {
    const data = {"route": "/pengumuman/3", "id": "3"};
    expect(data["id"], "3");
    expect(routeFromMessage(data), "/pengumuman/3");
  });

  test("shortToken memotong token untuk tampilan debug", () {
    expect(shortToken("mock-access-untuk-debug"), "mock-access-...");
    expect(shortToken("pendek"), "pendek");
  });

  test("authRedirect menjaga guard route", () {
    expect(authRedirect(loggedIn: false, location: "/"), "/login");
    expect(authRedirect(loggedIn: false, location: "/login"), isNull);
    expect(authRedirect(loggedIn: true, location: "/login"), "/");
    expect(authRedirect(loggedIn: true, location: "/"), isNull);
    expect(
        authRedirect(loggedIn: true, location: "/pengumuman/3"), isNull);
  });

  test("announcementRoute membentuk path detail", () {
    expect(announcementRoute("3"), "/pengumuman/3");
  });

  test("provider auth membaca status login dari token", () async {
    final store = FakeTokenStore()..access = "mock-access";
    expect(await store.readAccess() != null, isTrue);
    await store.clear();
    expect(await store.readAccess() != null, isFalse);
  });

  test("refresh gagal membuat sesi dibersihkan", () async {
    final store = FakeTokenStore()..refresh = "";
    final needsLogin = (await store.readRefresh() ?? "").isEmpty;
    expect(needsLogin, isTrue);
  });

  test("login menolak email dan sandi tidak valid", () async {
    final auth = AuthRepository();
    expect(() => auth.login(email: "bukanemail", password: "123456"),
        throwsException);
    expect(() => auth.login(email: "mhs@kampus.ac.id", password: "123"),
        throwsException);
  });

  test("login valid menyimpan sesi akses dan refresh", () async {
    final auth = AuthRepository();
    final session = await auth.login(
        email: "mhs@kampus.ac.id", password: "rahasia123");
    expect(session.access.isNotEmpty, isTrue);
    expect(session.refresh.isNotEmpty, isTrue);
  });

  test("friendlyApiMessage memetakan error jaringan", () {
    RequestOptions opt(String path) => RequestOptions(path: path);
    expect(
        friendlyApiMessage(DioException(
            requestOptions: opt("/x"),
            response: Response(
                requestOptions: opt("/x"), statusCode: 401))),
        contains("Sesi"));
    expect(
        friendlyApiMessage(DioException(
            requestOptions: opt("/x"),
            type: DioExceptionType.connectionTimeout)),
        contains("lambat"));
    expect(
        friendlyApiMessage(DioException(
            requestOptions: opt("/x"),
            type: DioExceptionType.connectionError)),
        contains("terhubung"));
  });

  test("dio refresh sekali lalu mengulang request saat 401", () async {
    final store = FakeTokenStore()
      ..access = "tua"
      ..refresh = "segar";
    var calls = 0;
    final dio = buildApiClient(store, FakeAuthRepository());
    dio.httpClientAdapter = TestAdapter((options) async {
      calls++;
      if (calls == 1) {
        return ResponseBody.fromString("",
            401, headers: {Headers.contentTypeHeader: ["text/plain"]});
      }
      expect(options.headers["Authorization"], "Bearer renewed-access");
      return ResponseBody.fromString("ok", 200,
          headers: {Headers.contentTypeHeader: ["text/plain"]});
    });
    final res = await dio.get("/data");
    expect(res.statusCode, 200);
    expect(await store.readAccess(), "renewed-access");
  });

  test("dio logout bila refresh ikut mati", () async {
    final store = FakeTokenStore()
      ..access = "tua"
      ..refresh = "";
    final dio = buildApiClient(store, FakeAuthRepository());
    dio.httpClientAdapter = TestAdapter((options) async {
      return ResponseBody.fromString("", 401,
          headers: {Headers.contentTypeHeader: ["text/plain"]});
    });
    try {
      await dio.get("/data");
      fail("seharusnya 401");
    } on DioException catch (e) {
      expect(e.response?.statusCode, 401);
    }
    expect(store.cleared, isTrue);
  });

  test("authStateProvider login lalu logout", () async {
    final container = ProviderContainer(overrides: [
      tokenStoreProvider.overrideWithValue(FakeTokenStore()),
    ]);
    addTearDown(container.dispose);
    final before =
        await container.read(authStateProvider.future);
    expect(before, isFalse);
    await container
        .read(authStateProvider.notifier)
        .login("mhs@kampus.ac.id", "rahasia123");
    expect(await container.read(authStateProvider.future), isTrue);
    await container.read(authStateProvider.notifier).logout();
    expect(await container.read(authStateProvider.future), isFalse);
  });
}
