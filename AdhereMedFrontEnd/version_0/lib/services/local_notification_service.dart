// lib/services/local_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Method to schedule notifications
  static Future<void> scheduleMedicationNotification(
      int id, String title, String body, DateTime scheduledTime) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // Notification ID
      title, // Notification title
      body, // Notification body
      tz.TZDateTime.from(scheduledTime, tz.local), // Scheduled time
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel', // Channel ID
          'Medication Reminders', // Channel Name

          importance: Importance.high, // Notification importance
          priority: Priority.high, // Notification priority
        ),
      ), // Notification details
      androidAllowWhileIdle:
          true, // Allow the notification to show even if the app is idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // Time interpretation
    );
  }
}
