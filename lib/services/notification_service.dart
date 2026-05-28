import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  static String? fcmToken;

  static Future<void> init() async {
    await Firebase.initializeApp();
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permission: \${settings.authorizationStatus}');
    fcmToken = await messaging.getToken();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _local.initialize(const InitializationSettings(android: android));

    const channel = AndroidNotificationChannel('demontv_channel', 'DemonTv Notificaciones', importance: Importance.high);
    await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((msg) {
      final n = msg.notification;
      if (n != null) {
        _local.show(0, n.title, n.body,
          const NotificationDetails(android: AndroidNotificationDetails('demontv_channel', 'DemonTv Notificaciones', importance: Importance.high, priority: Priority.high)));
      }
    });

    FirebaseMessaging.onBackgroundMessage(_bgHandler);
  }

  static Future<void> _bgHandler(RemoteMessage msg) async {
    await Firebase.initializeApp();
  }
}
