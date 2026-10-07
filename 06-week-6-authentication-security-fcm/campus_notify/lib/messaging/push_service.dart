import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter_local_notifications/flutter_local_notifications.dart";
import "../routes.dart";

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

String routeFromMessage(Map<String, String> data) {
  final route = data["route"] ?? routeHome;
  return route.startsWith("/") ? route : "/$route";
}

String shortToken(String token) =>
    token.length <= 12 ? token : "${token.substring(0, 12)}...";

Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings("@mipmap/ic_launcher");
  const ios = DarwinInitializationSettings();
  await localNotifications.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload != null && payload.isNotEmpty) {
        pendingDeepLink = payload;
      }
    },
  );
}

Future<void> initFcmToken(
    {required Future<void> Function(String token) onToken}) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await onToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(onToken);
  await FirebaseMessaging.instance.subscribeToTopic(topicPengumuman);
}

Future<void> unsubscribePengumuman() {
  return FirebaseMessaging.instance.unsubscribeFromTopic(topicPengumuman);
}

void listenForeground(Future<void> Function(String title, String body,
        String route) showLocal) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(
        message.data.map((key, value) => MapEntry(key, value.toString())));
    await showLocal(message.notification?.title ?? "Pengumuman",
        message.notification?.body ?? "", route);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    pendingDeepLink = routeFromMessage(
        message.data.map((key, value) => MapEntry(key, value.toString())));
  });
}

Future<void> showPengumumanLocal(
    String title, String body, String route) async {
  const androidDetails = AndroidNotificationDetails(
    "pengumuman",
    "Pengumuman Kampus",
    importance: Importance.high,
    priority: Priority.high,
  );
  await localNotifications.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails:
        const NotificationDetails(android: androidDetails),
    payload: route,
  );
}

Future<String?> handleTerminated() async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    return routeFromMessage(
        initial.data.map((key, value) => MapEntry(key, value.toString())));
  }
  return pendingDeepLink;
}

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
