import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService extends GetxService {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<NotificationService> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    tz.initializeTimeZones();

    // Get the device's local timezone
    try {
      final result = await FlutterTimezone.getLocalTimezone();
      // Handle potential type mismatch if package returns an object instead of String
      final String timeZoneName = result.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone lookup fails
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // v17: Positional argument
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _requestPermissions();

    return this;
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    // Required for Android 12+ to schedule exact alarms
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleTaskNotification(TaskEntity task) async {
    print(
      '[NotificationService] scheduleTaskNotification called for task: ${task.title}',
    );
    print(
      '[NotificationService] Task ID: ${task.id}, Time: ${task.time}, DueDate: ${task.dueDate}',
    );

    await cancelTaskNotification(task.id);

    if (task.isCompleted) {
      print('[NotificationService] Task is completed, skipping notification');
      return;
    }

    DateTime now = DateTime.now();
    DateTime triggerDate;

    if (task.isLunarCalendar &&
        task.lunarDay != null &&
        task.lunarMonth != null) {
      print(
        '[NotificationService] Using lunar calendar: day=${task.lunarDay}, month=${task.lunarMonth}',
      );
      try {
        triggerDate = LunarCalendarUtils.lunarToSolar(
          day: task.lunarDay!,
          month: task.lunarMonth!,
          year: now.year,
          isLeapMonth: false,
        );
        DateTime triggerDateTime = _combineDateAndTime(triggerDate, task.time);
        if (triggerDateTime.isBefore(now)) {
          triggerDate = LunarCalendarUtils.lunarToSolar(
            day: task.lunarDay!,
            month: task.lunarMonth!,
            year: now.year + 1,
            isLeapMonth: false,
          );
        }
      } catch (e) {
        print('[NotificationService] Error converting lunar date: $e');
        return;
      }
    } else if (task.dueDate != null) {
      triggerDate = task.dueDate!;
      print(
        '[NotificationService] Using solar calendar: triggerDate=$triggerDate',
      );
    } else {
      print('[NotificationService] No due date, skipping notification');
      return;
    }

    DateTime scheduledDate = _combineDateAndTime(triggerDate, task.time);

    print(
      '[NotificationService] Scheduled date/time: $scheduledDate, Now: $now',
    );

    if (scheduledDate.isBefore(now)) {
      print('[NotificationService] Scheduled date is in the past, skipping');
      return;
    }

    int notificationId = task.id.hashCode;
    print(
      '[NotificationService] Scheduling notification with ID: $notificationId',
    );

    try {
      // v17: Positional arguments for id, title, body, scheduledDate, notificationDetails
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        task.title,
        null,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel_id',
            'Task Notifications',
            channelDescription: 'Notifications for tasks',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('[NotificationService] Notification scheduled successfully!');
    } catch (e) {
      print('[NotificationService] Error scheduling notification: $e');
    }
  }

  /// Combines date and time.
  /// If no time is specified, defaults to 00:00:01 - notifications will still fire at midnight for future dates.
  DateTime _combineDateAndTime(DateTime date, DateTime? time) {
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } else {
      // Default to 00:00:01 for tasks without specific time
      return DateTime(date.year, date.month, date.day, 0, 0, 1);
    }
  }

  /// Schedule a test notification 10 seconds from now
  Future<void> scheduleTestNotification() async {
    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(seconds: 10));
    final id = now.millisecondsSinceEpoch ~/ 1000;

    print(
      '[NotificationService] Scheduling test notification for $scheduledDate',
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Test Scheduled Notification',
        'Thông báo này được hẹn giờ 10s trước.',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel_id',
            'Test Notifications',
            channelDescription: 'Test notification channel',
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('[NotificationService] Test schedule success');
    } catch (e) {
      print('[NotificationService] Test schedule failed: $e');
      rethrow; // Re-throw to show in UI
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    // v17: Positional argument
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Test method to show an immediate notification
  /// Call this to verify notifications are working at all
  Future<void> showTestNotification() async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'Nếu bạn thấy thông báo này, notifications đang hoạt động!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel_id',
          'Test Notifications',
          channelDescription: 'Test notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Get list of pending notifications for debugging
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
