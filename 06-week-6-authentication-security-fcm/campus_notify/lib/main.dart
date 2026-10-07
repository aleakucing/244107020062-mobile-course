import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "messaging/push_service.dart";
import "pages/announcement_page.dart";
import "pages/home_page.dart";
import "pages/login_page.dart";
import "providers/auth_provider.dart";
import "routes.dart";

final _rootKey = GlobalKey<NavigatorState>();

void _go(String route) {
  final context = _rootKey.currentContext;
  if (context != null) context.go(route);
}

Future<void> initPushOnDevice(WidgetRef ref) async {
  try {
    await initLocalNotifications();
  } catch (_) {}
  try {
    registerBackgroundHandler();
  } catch (_) {}
  try {
    await initFcmToken(onToken: (token) async {
      try {
        await ref.read(apiClientProvider).post("/devices",
            data: {"fcm_token": token, "platform": "android"});
      } catch (_) {}
    });
  } catch (_) {}
  listenForeground((title, body, route) async {
    await showPengumumanLocal(title, body, route);
  });
  try {
    final route = await handleTerminated();
    if (route != null) _go(route);
  } catch (_) {}
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: routeHome,
    redirect: (context, state) {
      final loggedIn = ref.read(authStateProvider).value ?? false;
      return authRedirect(
          loggedIn: loggedIn, location: state.matchedLocation);
    },
    routes: [
      GoRoute(path: routeLogin, builder: (_, _) => const LoginPage()),
      GoRoute(path: routeHome, builder: (_, _) => const HomePage()),
      GoRoute(
        path: routeAnnouncementPattern,
        builder: (_, s) =>
            AnnouncementPage(id: s.pathParameters["id"] ?? ""),
      ),
    ],
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  runApp(const ProviderScope(child: CampusApp()));
}

class CampusApp extends ConsumerStatefulWidget {
  const CampusApp({super.key, this.enablePush = true});
  final bool enablePush;

  @override
  ConsumerState<CampusApp> createState() => _CampusAppState();
}

class _CampusAppState extends ConsumerState<CampusApp> {
  @override
  void initState() {
    super.initState();
    if (widget.enablePush) {
      Future.microtask(() => initPushOnDevice(ref));
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: "Campus Notify - Week 6",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
