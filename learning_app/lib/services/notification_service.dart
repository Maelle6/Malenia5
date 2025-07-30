import 'package:deadline_repository/deadline_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer; // For logging
import 'package:task_repository/task_repository.dart'; // Assuming your Task class is here

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    // Set the default timezone to Indian/Mauritius
    try {
      tz.setLocalLocation(tz.getLocation('Indian/Mauritius'));
    } catch (e) {
      developer.log("Error setting timezone: $e");
    }

    // Request permissions for Android 13+ devices
    await _requestAndroidPermission();

    // Define Android notification settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Set up initialization settings for Android and iOS
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    // Initialize the plugin with the settings
    await _notificationsPlugin.initialize(initSettings);

    // Request permissions for iOS devices
    await requestPermissions();
  }

  // Request permissions for Android 13+ devices
  Future<void> _requestAndroidPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
      status = await Permission.notification.status;
    }
    developer.log("Notification Permission Status: $status");
  }

  // Request permissions for iOS devices
  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Schedule one-day-before reminders
  Future<void> scheduleOneDayBeforeReminder(Task task) async {
    // Due date at midnight
    final dueDateAtMidnight =
        DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

    // Calculate one day before the due date
    final oneDayBefore = dueDateAtMidnight.subtract(const Duration(days: 1));

    // Set notification time as the max of "oneDayBefore + default time" and "current time"
    final now = DateTime.now();
    final oneDayBeforeReminderTIme = oneDayBefore.isAfter(now)
        ? oneDayBefore
        : now.add(const Duration(
            minutes:
                1)); // Schedule at least 5 minutes later if oneDayBefore is in the past

    if (task.dueDate.isAfter(DateTime.now())) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'one_day_before_channel',
        'One-Day Task Reminder',
        channelDescription: 'Reminders one day before a task is due',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final notificationTime =
          tz.TZDateTime.from(oneDayBeforeReminderTIme, tz.local);
      print("One-Day Reminder Time for '${task.title}': $notificationTime");
      print("${task.notificationId}");

      await _notificationsPlugin.zonedSchedule(
        // task.taskId.hashCode,
        task.notificationId,
        'Upcoming Task Reminder',
        'Reminder: ${task.title} is due tomorrow!',
        notificationTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Schedule same-day reminders
  Future<void> scheduleSameDayReminder(Task task) async {
    // Format
    final formattedCurrentTime =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final dueDate =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(task.dueDate));

    // Normalize due date and current time to avoid microsecond precision issues
    if (dueDate.isAtSameMomentAs(formattedCurrentTime)) {
      var sameDayReminderTime = DateTime.now().add(const Duration(hours: 3));
      // Get the current date and time
      final today = DateTime.now();
      // Calculate tomorrow's date at midnight
      final tomorrowAtMidnight =
          DateTime(today.year, today.month, today.day + 1);

      print("Same due time = $sameDayReminderTime");
      print("Is overdue = $tomorrowAtMidnight");

      if (sameDayReminderTime.isBefore(tomorrowAtMidnight)) {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'same_day_channel',
          'Same-Day Task Reminder',
          channelDescription:
              'Reminders 6 hours after task creation if due today',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
        );

        final notificationTime =
            tz.TZDateTime.from(sameDayReminderTime, tz.local);
        print("Same-Day Reminder Time for '${task.title}': $notificationTime");

        await _notificationsPlugin.zonedSchedule(
          task.notificationId,
          'Same-Day Reminder',
          'Reminder: ${task.title} is due today!',
          notificationTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

// Schedule one-day-before reminders for Deadline
  Future<void> scheduleOneDayBeforeReminderForDeadline(
      Deadline deadline) async {
    // Due date at midnight
    final dueDateAtMidnight = DateTime(
        deadline.dueDate.year, deadline.dueDate.month, deadline.dueDate.day);

    // Calculate one day before the due date
    final oneDayBefore = dueDateAtMidnight.subtract(const Duration(days: 1));

    // Set notification time as the max of "oneDayBefore + default time" and "current time"
    final now = DateTime.now();
    final oneDayBeforeReminderTIme = oneDayBefore.isAfter(now)
        ? oneDayBefore
        : now.add(const Duration(
            minutes:
                1)); // Schedule at least 5 minutes later if oneDayBefore is in the past

    if (deadline.dueDate.isAfter(DateTime.now())) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'one_day_before_channel',
        'One-Day Task Reminder',
        channelDescription: 'Reminders one day before a task is due',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final notificationTime =
          tz.TZDateTime.from(oneDayBeforeReminderTIme, tz.local);
      print("One-Day Reminder Time for '${deadline.title}': $notificationTime");
      print("${deadline.notificationId}");

      await _notificationsPlugin.zonedSchedule(
        // task.taskId.hashCode,
        deadline.notificationId,
        'Upcoming Deadline Reminder',
        'Reminder: ${deadline.title} is due tomorrow!',
        notificationTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Schedule same-day reminders For Deadline
  Future<void> scheduleSameDayReminderForDeadline(Deadline deadline) async {
    // Format
    final formattedCurrentTime =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final dueDate =
        DateTime.parse(DateFormat('yyyy-MM-dd').format(deadline.dueDate));

    // Normalize due date and current time to avoid microsecond precision issues
    if (dueDate.isAtSameMomentAs(formattedCurrentTime)) {
      var sameDayReminderTime = DateTime.now().add(const Duration(hours: 3));
      // Get the current date and time
      final today = DateTime.now();
      // Calculate tomorrow's date at midnight
      final tomorrowAtMidnight =
          DateTime(today.year, today.month, today.day + 1);

      print("Same due time = $sameDayReminderTime");
      print("Is overdue = $tomorrowAtMidnight");

      if (sameDayReminderTime.isBefore(tomorrowAtMidnight)) {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'same_day_channel',
          'Same-Day Task Reminder',
          channelDescription:
              'Reminders 3 hours after task creation if due today',
          importance: Importance.max,
          priority: Priority.high,
        );

        const NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
        );

        final notificationTime =
            tz.TZDateTime.from(sameDayReminderTime, tz.local);
        print(
            "Same-Day Reminder Time for '${deadline.title}': $notificationTime");

        await _notificationsPlugin.zonedSchedule(
          deadline.notificationId,
          'Same-Day Reminder',
          'Reminder: ${deadline.title} is due today!',
          notificationTime,
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    print('cancelling notification for $notificationId');
    await _notificationsPlugin.cancel(notificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
