import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';

class NotificationService extends GetxService {
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<NotificationService> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

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
  }

  Future<void> scheduleTaskNotification(TaskEntity task) async {
    // Cancel existing notification for this task first to avoid duplicates
    await cancelTaskNotification(task.id);

    if (task.isCompleted) return;

    // Calculate the trigger date time
    DateTime now = DateTime.now();
    DateTime triggerDate;

    if (task.isLunarCalendar &&
        task.lunarDay != null &&
        task.lunarMonth != null) {
      // Handle Lunar Date
      // Try to get solar date for current year
      try {
        triggerDate = LunarCalendarUtils.lunarToSolar(
          day: task.lunarDay!,
          month: task.lunarMonth!,
          year: now.year,
          isLeapMonth: false, // Assuming not leap for simplicity or need check
        );

        // If the date has passed, use next year (simple logic, improves later)
        // But we also need to respect the task time.
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
        // Fallback or skip if conversion fails
        return;
      }
    } else {
      // Handle Solar Date
      triggerDate = task.dueDate;
    }

    // Combine date with time (or start of day if no time)
    DateTime scheduledDate = _combineDateAndTime(triggerDate, task.time);

    // If the time is in the past, don't schedule (or schedule for next occurrence if recurring - simplified for now)
    if (scheduledDate.isBefore(now)) return;

    // Use a unique ID based on task ID hash
    int notificationId = task.id.hashCode;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      task.title,
      task.isLunarCalendar
          ? 'Lịch âm: ${task.lunarDay}/${task.lunarMonth}'
          : 'Lịch dương: ${triggerDate.day}/${triggerDate.month}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Notifications for tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  DateTime _combineDateAndTime(DateTime date, DateTime? time) {
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } else {
      // Getting first second of the day as requested: 00:00:01
      return DateTime(date.year, date.month, date.day, 0, 0, 1);
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
