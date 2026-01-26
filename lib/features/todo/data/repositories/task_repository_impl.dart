import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/data/datasources/local/task_local_datasource.dart';
import 'package:todo_lich_am/features/todo/data/models/task_model.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';

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
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _localDataSource.saveTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<TaskEntity> toggleComplete(String id) async {
    final task = await getTaskById(id);
    if (task == null) {
      throw Exception('Task not found');
    }

    TaskEntity updatedTask;

    if (!task.isCompleted) {
      // Marking as complete
      if (task.repeatType != RepeatType.none) {
        // Calculate next occurrence for recurring tasks
        final nextDate = task.isLunarCalendar
            ? LunarCalendarUtils.getNextLunarRecurrence(
                currentDate: task.dueDate,
                repeatType: task.repeatType.value,
              )
            : LunarCalendarUtils.getNextSolarRecurrence(
                currentDate: task.dueDate,
                repeatType: task.repeatType.value,
              );

        // Update lunar date info if using lunar calendar
        int? lunarDay, lunarMonth, lunarYear;
        if (task.isLunarCalendar) {
          final lunar = LunarCalendarUtils.solarToLunar(nextDate);
          lunarDay = lunar.getDay();
          lunarMonth = lunar.getMonth();
          lunarYear = lunar.getYear();
        }

        updatedTask = task.copyWith(
          dueDate: nextDate,
          isCompleted: false,
          completedAt: DateTime.now(),
          lunarDay: lunarDay,
          lunarMonth: lunarMonth,
          lunarYear: lunarYear,
        );
      } else {
        // Non-recurring task, just mark complete
        updatedTask = task.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }
    } else {
      // Marking as incomplete
      updatedTask = task.copyWith(isCompleted: false, completedAt: null);
    }

    await updateTask(updatedTask);
    return updatedTask;
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
}
