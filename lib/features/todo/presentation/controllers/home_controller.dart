import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';

import 'package:todo_lich_am/common/widgets/first_run_dialog.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';

/// Tab type for filtering.
enum TabType { favorites, myTasks, calendar }

/// Calendar type for filtering.
enum CalendarFilter { all, solar, lunar }

/// Controller for HomePage.
class HomeController extends GetxController {
  final TaskRepository _repository;

  HomeController(this._repository);

  // Observable state
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;
  final RxBool isLoading = true.obs;
  final Rx<TabType> currentTab = TabType.myTasks.obs;
  final Rx<CalendarFilter> currentFilter = CalendarFilter.all.obs;
  final RxBool isSearching = false.obs;
  final RxString searchText = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Navigation state
  final RxInt currentNavIndex = 0.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> focusedDay = DateTime.now().obs;

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
    // Wait for initial load to finish
    if (isLoading.value) {
      await 500.milliseconds.delay();
    }

    if (tasks.isEmpty) {
      final result = await Get.dialog<bool>(
        FirstRunDialog(taskRepository: _repository),
        barrierDismissible: false,
      );

      if (result == true) {
        debugPrint('HomeController: Dialog returned true, reloading tasks...');

        // Wait for dialog animation to complete and Hive to settle
        await 500.milliseconds.delay();

        // Force reload tasks directly
        await loadTasks();

        // If still empty, retry once more after a longer delay
        if (tasks.isEmpty) {
          debugPrint('HomeController: Tasks still empty, retrying...');
          await 500.milliseconds.delay();
          await loadTasks();
        }

        debugPrint(
          'HomeController: Final task count after adding holidays: ${tasks.length}',
        );
      }
    }
  }

  /// Loads tasks from repository.
  Future<void> loadTasks() async {
    isLoading.value = true;
    update();

    try {
      final List<TaskEntity> fetchedTasks =
          (currentTab.value == TabType.favorites)
          ? await _repository.getStarredTasks()
          : await _repository.getAllTasks();

      tasks.value = fetchedTasks;
      _sortTasks();
      debugPrint(
        'HomeController: Loaded ${tasks.length} tasks on ${currentTab.value}',
      );
    } finally {
      isLoading.value = false;
      tasks.refresh();
      update();
    }
  }

  /// Switches to a different tab.
  void switchTab(TabType tab) {
    if (currentTab.value != tab) {
      currentTab.value = tab;
      loadTasks();
    }
  }

  /// Switches filter.
  void setFilter(CalendarFilter filter) {
    if (currentFilter.value != filter) {
      currentFilter.value = filter;
      update();
    }
  }

  /// Toggles search mode.
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }

  /// Clears search text.
  void clearSearch() {
    searchText.value = '';
    searchController.clear();
    update();
  }

  /// Updates search text.
  void onSearchChanged(String value) {
    searchText.value = value;
    update();
  }

  void _sortTasks() {
    tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Groups uncompleted tasks by date for display.
  Map<DateTime, List<TaskEntity>> get groupedTasks {
    final Map<DateTime, List<TaskEntity>> grouped = {};

    for (final task in tasks.where((t) => !t.isCompleted)) {
      if (currentFilter.value == CalendarFilter.solar && task.isLunarCalendar)
        continue;
      if (currentFilter.value == CalendarFilter.lunar && !task.isLunarCalendar)
        continue;

      if (searchText.isNotEmpty) {
        final query = searchText.value.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !descMatch) continue;
      }

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

  /// Gets tasks for a specific date (Solar).
  List<TaskEntity> getTasksForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    // Combine both active and completed tasks?
    // Usually calendar shows all.
    final allTasks = [...tasks];
    return allTasks.where((task) {
      final tDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return tDate.isAtSameMomentAs(dateKey);
    }).toList();
  }

  /// Groups completed tasks by date for display.
  Map<DateTime, List<TaskEntity>> get groupedCompletedTasks {
    final Map<DateTime, List<TaskEntity>> grouped = {};

    for (final task in tasks.where((t) => t.isCompleted)) {
      if (currentFilter.value == CalendarFilter.solar && task.isLunarCalendar)
        continue;
      if (currentFilter.value == CalendarFilter.lunar && !task.isLunarCalendar)
        continue;

      if (searchText.isNotEmpty) {
        final query = searchText.value.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch =
            task.description?.toLowerCase().contains(query) ?? false;
        if (!titleMatch && !descMatch) continue;
      }

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
      final updatedTask = await _repository.toggleComplete(taskId);
      _showCompletionSnackbar(updatedTask);
      loadTasks();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật công việc');
    }
  }

  void _showCompletionSnackbar(TaskEntity task) {
    if (!task.isCompleted && task.repeatType == RepeatType.none) {
      // This was an uncheck (marking as incomplete), don't show "Completed" snackbar
      return;
    }

    final settings = Get.find<SettingsService>();
    final locale = settings.locale.value;
    final isVi = locale == 'vi';

    final titleText = isVi ? 'Thông báo' : 'Notification';
    final completedText = isVi
        ? 'Đã hoàn thành: ${task.title}'
        : 'Completed: ${task.title}';

    Widget messageWidget;

    if (!task.isCompleted) {
      // It was a recurring task, and this is the next occurrence
      final isLunar = task.isLunarCalendar;
      String nextDateStr;

      final dayOfWeek = LunarCalendarUtils.getDayOfWeekVietnamese(
        task.dueDate.weekday,
        locale,
      );

      if (isLunar) {
        final lunar = LunarCalendarUtils.solarToLunar(task.dueDate);
        final canChi = LunarCalendarUtils.getVietnameseGanZhiYear(
          lunar.getYear(),
        );
        nextDateStr =
            '$dayOfWeek, ${lunar.getDay()}/${lunar.getMonth()}/${lunar.getYear()} - $canChi';
      } else {
        nextDateStr =
            '$dayOfWeek, ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}';
      }

      messageWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(completedText, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                isVi ? 'Lịch kế tiếp: ' : 'Next occurrence: ',
                style: const TextStyle(color: Colors.white),
              ),
              Icon(
                isLunar ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
                size: 16,
                color: Colors.white, // Keep white for contrast on green bg
              ),
              const SizedBox(width: 4),
              Text(
                nextDateStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Non-recurring task
      messageWidget = Text(
        completedText,
        style: const TextStyle(color: Colors.white),
      );
    }

    Get.snackbar(
      titleText,
      '', // Message is replaced by messageText
      messageText: messageWidget,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
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

  /// Toggles task completion status.
  Future<void> toggleTaskComplete(TaskEntity task) async {
    try {
      if (!task.isCompleted) {
        // Toggle from incomplete to complete
        final updatedTask = await _repository.toggleComplete(task.id);
        _showCompletionSnackbar(updatedTask);
      } else {
        // Toggle from complete to incomplete
        await _repository.toggleComplete(task.id);
      }
      loadTasks();
    } catch (e) {
      debugPrint('Error updating task: $e');
      Get.snackbar('Lỗi', 'Không thể cập nhật công việc');
    }
  }

  /// Toggles task starred status.
  Future<void> toggleTaskStar(TaskEntity task) async {
    final updatedTask = task.copyWith(isStarred: !task.isStarred);
    await _updateTask(updatedTask);
  }

  Future<void> _updateTask(TaskEntity task) async {
    try {
      await _repository.updateTask(task);
      loadTasks();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }
}
