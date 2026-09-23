import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final androidPlatform = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        final granted =
            await androidPlatform.requestNotificationsPermission() ?? false;
        return granted;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] Request permission error: $e');
      return false;
    }
  }

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'dailycart_reminders',
      'DailyCart Shopping Reminders',
      channelDescription: 'Reminders for shopping lists and unchecked items',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.show(id, title, body, notificationDetails);
    } catch (e) {
      debugPrint('[NotificationService] Show notification error: $e');
    }
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('[NotificationService] Cancel error: $e');
    }
  }
}
