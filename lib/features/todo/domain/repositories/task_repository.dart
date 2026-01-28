import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';

/// Abstract repository interface for task operations.
abstract class TaskRepository {
  /// Gets all tasks.
  Future<List<TaskEntity>> getAllTasks();

  /// Gets tasks by category.
  Future<List<TaskEntity>> getTasksByCategory(String category);

  /// Gets starred tasks.
  Future<List<TaskEntity>> getStarredTasks();

  /// Gets a single task by ID.
  Future<TaskEntity?> getTaskById(String id);

  /// Adds a new task.
  Future<void> addTask(TaskEntity task);

  /// Updates an existing task.
  Future<void> updateTask(TaskEntity task);

  /// Deletes a task by ID.
  Future<void> deleteTask(String id);

  /// Toggles task completion status.
  Future<TaskEntity> toggleComplete(String id);

  /// Toggles task starred status.
  Future<TaskEntity> toggleStar(String id);

  /// Deletes all tasks from storage.
  Future<void> deleteAllTasks();

  /// Deletes only completed tasks from storage.
  Future<void> deleteCompletedTasks();
}
