import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  bool _initialized = false;

  static final List<Map<String, dynamic>> _receivedNotifications = [];
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  List<Map<String, dynamic>> getReceivedNotifications() {
    return List.unmodifiable(_receivedNotifications);
  }

  void addNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) {
    _receivedNotifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'type': type ?? 'general',
      'timestamp': 'මෑතදී',
      'isRead': false,
      'data': data ?? {},
    });
    unreadCountNotifier.value = _receivedNotifications.where((n) => n['isRead'] == false).length;
  }

  Future<void> initNotifications({String? userId}) async {
    if (_initialized) return;
    _initialized = true;

    // 1. Request Notification Permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint("User granted notification permission: ${settings.authorizationStatus}");

    // 2. Setup Local Notification Channel for Android Foreground Alerts
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: DarwinInitializationSettings(),
      );

      await _localNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint("Notification tapped: ${details.payload}");
        },
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 3. Register FCM Token with Backend
    try {
      await syncFcmToken(userId: userId);
    } catch (e) {
      debugPrint("⚠️ FCM sync notice: $e");
    }

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      syncFcmToken(userId: userId, tokenOverride: newToken);
    });

    // 4. Foreground Message Listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String currentRole = prefs.getString('role') ?? 'customer';

        String recipientRole = (message.data['recipientRole'] ?? '').toString();
        String nTitle = (notification.title ?? '').toString();

        // Role-based notification filtering:
        // Skip provider-targeted new booking alerts if current user is logged in as customer
        if (recipientRole == 'provider' && currentRole != 'provider') {
          debugPrint("⏩ Skipping notification intended for provider because current role is $currentRole");
          return;
        }
        if (nTitle.contains('අලුත් සේවා ඉල්ලීමක්') && currentRole == 'customer') {
          debugPrint("⏩ Skipping provider new booking alert for customer role.");
          return;
        }

        addNotification(
          title: notification.title ?? 'දැනුම්දීමයි',
          body: notification.body ?? '',
          type: message.data['type'] ?? 'general',
          data: message.data,
        );

        if (!kIsWeb) {
          _localNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: jsonEncode(message.data),
          );
        }
      }
    });

    // 5. Message Opened App (Tap on notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened app: ${message.data}");
    });
  }

  // Sync FCM token to backend DB
  Future<void> syncFcmToken({String? userId, String? tokenOverride}) async {
    try {
      String? targetUserId = userId;
      if (targetUserId == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        targetUserId = prefs.getString('userId');
      }

      if (targetUserId == null || targetUserId.isEmpty) return;

      String? token = tokenOverride;
      if (token == null && !kIsWeb) {
        try {
          token = await _firebaseMessaging.getToken().timeout(
            const Duration(seconds: 3),
            onTimeout: () => null,
          );
        } catch (tokenErr) {
          debugPrint("⚠️ getToken error: $tokenErr");
        }
      }

      if (token != null && token.isNotEmpty) {
        debugPrint("📱 Device FCM Token: $token");
        await ApiService.updateFcmToken(
          userId: targetUserId,
          fcmToken: token,
        );
      }
    } catch (e) {
      debugPrint("⚠️ Error syncing FCM Token: $e");
    }
  }
}
