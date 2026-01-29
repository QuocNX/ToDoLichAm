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
  }

  Future<void> scheduleTaskNotification(TaskEntity task) async {
    await cancelTaskNotification(task.id);

    if (task.isCompleted) return;

    DateTime now = DateTime.now();
    DateTime triggerDate;

    if (task.isLunarCalendar &&
        task.lunarDay != null &&
        task.lunarMonth != null) {
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
        return;
      }
    } else {
      triggerDate = task.dueDate;
    }

    DateTime scheduledDate = _combineDateAndTime(triggerDate, task.time);

    if (scheduledDate.isBefore(now)) return;

    int notificationId = task.id.hashCode;

    // v17: Positional arguments for id, title, body, scheduledDate, notificationDetails
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      task.title,
      task.isLunarCalendar
          ? 'Lịch âm: ${task.lunarDay}/${task.lunarMonth}'
          : 'Lịch dương: ${triggerDate.day}/${triggerDate.month}',
      tz.TZDateTime.from(scheduledDate, tz.UTC),
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
      return DateTime(date.year, date.month, date.day, 0, 0, 1);
    }
  }

  Future<void> cancelTaskNotification(String taskId) async {
    // v17: Positional argument
    await _flutterLocalNotificationsPlugin.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
