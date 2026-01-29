import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/data/datasources/local/task_local_datasource.dart';
import 'package:todo_lich_am/features/todo/data/models/task_model.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

/// Implementation of TaskRepository using local storage.
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl(this._localDataSource);

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final models = await _localDataSource.getAllTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getTasksByCategory(String category) async {
    final models = await _localDataSource.getTasksByCategory(category);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TaskEntity>> getStarredTasks() async {
    final models = await _localDataSource.getStarredTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    final model = await _localDataSource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.saveTask(model);
    _scheduleNotification(task);
  }

  @override
  Future<void> addAllTasks(List<TaskEntity> tasks) async {
    final models = tasks.map((t) => TaskModel.fromEntity(t)).toList();
    await _localDataSource.saveAllTasks(models);
    for (final task in tasks) {
      _scheduleNotification(task);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.saveTask(model);
    _scheduleNotification(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
    _cancelNotification(id);
  }

  @override
  Future<TaskEntity> toggleComplete(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    if (!task.isCompleted) {
      // Marking as complete
      if (task.repeatType != RepeatType.none) {
        // For recurring tasks:
        // 1. Create a completed copy for history (current date)
        final completedTask = TaskEntity(
          id: const Uuid().v4(), // Generate new ID for history item
          title: task.title,
          description: task.description,
          dueDate: task.dueDate, // Keep original due date for history
          time: task.time,
          isLunarCalendar: task.isLunarCalendar,
          repeatType: RepeatType.none, // History item doesn't repeat
          repeatInterval: 1,
          isCompleted: true, // Mark as completed
          isStarred: task.isStarred,
          category: task.category,
          createdAt: task
              .createdAt, // Keep original creation time? Or now? Usually original.
          completedAt: DateTime.now(),
          lunarDay: task.lunarDay,
          lunarMonth: task.lunarMonth,
          lunarYear: task.lunarYear,
        );

        // Save the completed copy
        await addTask(completedTask);

        // 2. Calculate next occurrence for the original task
        final nextDate = task.isLunarCalendar
            ? LunarCalendarUtils.getNextLunarRecurrence(
                currentDate: task.dueDate,
                repeatType: task.repeatType.value,
                repeatInterval: task.repeatInterval,
              )
            : LunarCalendarUtils.getNextSolarRecurrence(
                currentDate: task.dueDate,
                repeatType: task.repeatType.value,
                repeatInterval: task.repeatInterval,
              );

        // Update lunar date info if using lunar calendar
        int? lunarDay, lunarMonth, lunarYear;
        if (task.isLunarCalendar) {
          final lunar = LunarCalendarUtils.solarToLunar(nextDate);
          lunarDay = lunar.getDay();
          lunarMonth = lunar.getMonth();
          lunarYear = lunar.getYear();
        }

        // Reschedule the original task
        final updatedTask = task.copyWith(
          dueDate: nextDate,
          lunarDay: lunarDay,
          lunarMonth: lunarMonth,
          lunarYear: lunarYear,
          // Keep other fields (isCompleted = false)
        );

        await updateTask(updatedTask);
        return updatedTask;
      } else {
        // Non-recurring task, just mark complete
        final updatedTask = task.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        await updateTask(updatedTask);
        return updatedTask;
      }
    } else {
      // Marking as incomplete (unchecking from history)
      final updatedTask = task.copyWith(isCompleted: false, completedAt: null);
      await updateTask(updatedTask);
      return updatedTask;
    }
  }

  @override
  Future<TaskEntity> toggleStar(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    final updatedTask = task.copyWith(isStarred: !task.isStarred);
    await updateTask(updatedTask);
    return updatedTask;
  }

  @override
  Future<void> deleteAllTasks() async {
    await _localDataSource.clearAllTasks();
    if (Get.isRegistered<NotificationService>()) {
      await Get.find<NotificationService>().cancelAll();
    }
  }

  @override
  Future<void> deleteCompletedTasks() async {
    // We should probably get the list of completed tasks ID first to cancel notifications?
    // But completed tasks naturally don't have pending notifications because
    // _scheduleNotification checks isCompleted.
    // However, if we delete them, we don't need to do anything specific for notifications
    // as they shouldn't exist.
    await _localDataSource.clearCompletedTasks();
  }

  // Helper methods for accessing NotificationService safely
  void _scheduleNotification(TaskEntity task) {
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().scheduleTaskNotification(task);
    }
  }

  void _cancelNotification(String taskId) {
    if (Get.isRegistered<NotificationService>()) {
      Get.find<NotificationService>().cancelTaskNotification(taskId);
    }
  }
}
