import 'package:get/get.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';

import 'package:todo_lich_am/common/widgets/first_run_dialog.dart';

/// Tab type for filtering.
enum TabType { favorites, myTasks }

/// Controller for HomePage.
class HomeController extends GetxController {
  final TaskRepository _repository;

  HomeController(this._repository);

  // Observable state
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<TabType> currentTab = TabType.myTasks.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  @override
  void onReady() {
    super.onReady();
    _checkFirstRun();
  }

  Future<void> _checkFirstRun() async {
    // If we're still loading, wait a bit
    if (isLoading.value) {
      await 1.seconds.delay();
    }

    if (tasks.isEmpty) {
      final result = await Get.dialog<bool>(
        FirstRunDialog(taskRepository: _repository),
        barrierDismissible: false,
      );

      if (result == true) {
        // Add a tiny delay to ensure dialog is closed and Hive is ready
        await Future.delayed(const Duration(milliseconds: 100));
        await loadTasks();
      }
    }
  }

  /// Loads tasks from repository.
  Future<void> loadTasks() async {
    isLoading.value = true;
    try {
      if (currentTab.value == TabType.favorites) {
        tasks.assignAll(await _repository.getStarredTasks());
      } else {
        tasks.assignAll(await _repository.getAllTasks());
      }
      _sortTasks();
    } finally {
      isLoading.value = false;
    }
  }

  /// Switches to a different tab.
  void switchTab(TabType tab) {
    if (currentTab.value != tab) {
      currentTab.value = tab;
      loadTasks();
    }
  }

  void _sortTasks() {
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Groups uncompleted tasks by date for display.
  Map<DateTime, List<TaskEntity>> get groupedTasks {
    final Map<DateTime, List<TaskEntity>> grouped = {};

    for (final task in tasks.where((t) => !t.isCompleted)) {
      final dateKey = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      grouped.putIfAbsent(dateKey, () => []).add(task);
    }

    // Sort the map by date
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  /// Groups completed tasks by date for display.
  Map<DateTime, List<TaskEntity>> get groupedCompletedTasks {
    final Map<DateTime, List<TaskEntity>> grouped = {};

    for (final task in tasks.where((t) => t.isCompleted)) {
      final dateKey = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      grouped.putIfAbsent(dateKey, () => []).add(task);
    }

    // Sort the map by date
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  /// Toggles task completion.
  Future<void> toggleComplete(String taskId) async {
    try {
      await _repository.toggleComplete(taskId);
      // Reload tasks to reflect potential new history items (for recurring tasks)
      // or rescheduled tasks
      loadTasks();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật công việc');
    }
  }

  /// Toggles task starred status.
  Future<void> toggleStar(String taskId) async {
    try {
      final updatedTask = await _repository.toggleStar(taskId);
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        if (currentTab.value == TabType.favorites && !updatedTask.isStarred) {
          // Remove from favorites list
          tasks.removeAt(index);
        } else {
          tasks[index] = updatedTask;
        }
        tasks.refresh();
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật yêu thích');
    }
  }

  /// Deletes a task.
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      tasks.removeWhere((t) => t.id == taskId);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa công việc');
    }
  }

  /// Gets the date header text for a date.
  String getDateHeader(DateTime date, String locale) {
    if (LunarCalendarUtils.isToday(date)) {
      return locale == 'vi' ? 'Hôm nay' : 'Today';
    }
    return LunarCalendarUtils.formatDateWithLunar(
      date,
      locale: locale,
      showLunar: true,
      showSolar: true,
    );
  }

  /// Gets days remaining text.
  String getDaysRemainingText(DateTime date, String locale) {
    final days = LunarCalendarUtils.daysRemaining(date);
    if (days == 0) return '';
    if (days > 0) {
      return locale == 'vi' ? 'Còn $days ngày' : '$days days left';
    } else {
      return locale == 'vi' ? 'Quá hạn ${-days} ngày' : '${-days} days overdue';
    }
  }

  /// Deletes all tasks from storage.
  Future<void> deleteAllTasks() async {
    try {
      isLoading.value = true;
      await _repository.deleteAllTasks();
      tasks.clear();
      Get.snackbar('Thành công', 'Đã xóa tất cả công việc');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa công việc');
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes only completed tasks from storage.
  Future<void> deleteCompletedTasks() async {
    try {
      isLoading.value = true;
      await _repository.deleteCompletedTasks();
      await loadTasks();
      Get.snackbar('Thành công', 'Đã xóa các việc đã hoàn thành');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa công việc');
    } finally {
      isLoading.value = false;
    }
  }
}
