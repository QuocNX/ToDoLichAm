import 'package:hive/hive.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';
import 'package:todo_lich_am/features/todo/data/models/task_model.dart';

/// Local data source for tasks using Hive.
class TaskLocalDataSource {
  Box<TaskModel>? _taskBox;

  /// Gets the task box, opening it if necessary.
  Future<Box<TaskModel>> get taskBox async {
    if (_taskBox == null || !_taskBox!.isOpen) {
      _taskBox = await Hive.openBox<TaskModel>(AppStrings.taskBoxName);
    }
    return _taskBox!;
  }

  /// Gets all tasks from local storage.
  Future<List<TaskModel>> getAllTasks() async {
    final box = await taskBox;
    return box.values.toList();
  }

  /// Gets tasks by category.
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    final box = await taskBox;
    return box.values.where((task) => task.category == category).toList();
  }

  /// Gets starred tasks.
  Future<List<TaskModel>> getStarredTasks() async {
    final box = await taskBox;
    return box.values.where((task) => task.isStarred).toList();
  }

  /// Gets a single task by ID.
  Future<TaskModel?> getTaskById(String id) async {
    final box = await taskBox;
    try {
      return box.values.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Saves a task to local storage.
  Future<void> saveTask(TaskModel task) async {
    final box = await taskBox;
    await box.put(task.id, task);
  }

  /// Deletes a task from local storage.
  Future<void> deleteTask(String id) async {
    final box = await taskBox;
    await box.delete(id);
  }

  /// Closes the box.
  Future<void> close() async {
    if (_taskBox != null && _taskBox!.isOpen) {
      await _taskBox!.close();
    }
  }
}
