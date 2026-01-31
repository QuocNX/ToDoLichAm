import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/home_controller.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/task_item_widget.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/date_group_header.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/calendar_view_widget.dart';
import 'package:todo_lich_am/routes/app_routes.dart';
import 'package:todo_lich_am/common/widgets/delete_tasks_dialog.dart';

/// Main home page displaying tasks grouped by date.
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            settings.locale.value == 'vi' ? 'Nhắc Việc' : 'Reminders',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: settings.locale.value == 'vi'
                      ? 'Cài đặt'
                      : 'Settings',
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        Icons.settings,
                        color: Colors.grey.shade600,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Tooltip(
                  message: settings.locale.value == 'vi' ? 'Xóa' : 'Delete',
                  child: InkWell(
                    onTap: () => _showDeleteAllDialog(context, settings),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Tooltip(
                  message: settings.locale.value == 'vi'
                      ? 'Thông tin'
                      : 'About',
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.about),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade400,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context, settings),
          Expanded(
            child: Obx(
              () => controller.currentTab.value == TabType.calendar
                  ? const CalendarViewWidget()
                  : _buildTaskList(context, settings),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.addTask);
          if (result == true) {
            controller.loadTasks();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        if (controller.isSearching.value) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: settings.locale.value == 'vi'
                                ? 'Tìm kiếm...'
                                : 'Search...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: controller.onSearchChanged,
                        ),
                      ),
                      if (controller.searchText.isNotEmpty)
                        GestureDetector(
                          onTap: controller.clearSearch,
                          child: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: controller.toggleSearch,
                child: Text(settings.locale.value == 'vi' ? 'Hủy' : 'Cancel'),
              ),
            ],
          );
        }

        return SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildTabItem(
                        context: context,
                        icon: Icons.star,
                        label: settings.locale.value == 'vi'
                            ? 'Yêu thích'
                            : 'Favorites',
                        isSelected:
                            controller.currentTab.value == TabType.favorites,
                        onTap: () => controller.switchTab(TabType.favorites),
                      ),
                      _buildTabItem(
                        context: context,
                        icon: Icons.list_alt,
                        label: settings.locale.value == 'vi'
                            ? 'Công việc'
                            : 'Tasks',
                        isSelected:
                            controller.currentTab.value == TabType.myTasks,
                        onTap: () => controller.switchTab(TabType.myTasks),
                      ),
                      _buildTabItem(
                        context: context,
                        label: settings.locale.value == 'vi'
                            ? 'Lịch'
                            : 'Calendar',
                        icon: Icons.calendar_month,
                        isSelected:
                            controller.currentTab.value == TabType.calendar,
                        onTap: () => controller.switchTab(TabType.calendar),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.currentTab.value != TabType.calendar) ...[
                const SizedBox(width: 12),
                _buildSearchButton(context),
                const SizedBox(width: 8),
                _buildFilterButton(context, settings),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return InkWell(
      onTap: controller.toggleSearch,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.search, size: 24, color: Colors.grey),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, SettingsService settings) {
    final isVi = settings.locale.value == 'vi';
    return PopupMenuButton<CalendarFilter>(
      initialValue: controller.currentFilter.value,
      onSelected: controller.setFilter,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: CalendarFilter.all,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(isVi ? 'Tất cả' : 'All'),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarFilter.solar,
          child: Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                size: 18,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(isVi ? 'Dương lịch' : 'Solar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: CalendarFilter.lunar,
          child: Row(
            children: [
              const Icon(
                Icons.nights_stay_outlined,
                size: 18,
                color: Colors.indigo,
              ),
              const SizedBox(width: 8),
              Text(isVi ? 'Âm lịch' : 'Lunar'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: controller.currentFilter.value != CalendarFilter.all
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.filter_list,
              size: 24,
              color: controller.currentFilter.value != CalendarFilter.all
                  ? AppColors.primary
                  : Colors.grey.shade600,
            ),
            if (controller.currentFilter.value != CalendarFilter.all) ...[
              const SizedBox(width: 4),
              Text(
                _getFilterLabel(controller.currentFilter.value, isVi),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(CalendarFilter filter, bool isVi) {
    switch (filter) {
      case CalendarFilter.solar:
        return isVi ? 'Dương' : 'Solar';
      case CalendarFilter.lunar:
        return isVi ? 'Âm' : 'Lunar';
      default:
        return '';
    }
  }

  Widget _buildTabItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, SettingsService settings) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final groupedTasks = controller.groupedTasks;
      final groupedCompletedTasks = controller.groupedCompletedTasks;

      final activeCount = groupedTasks.values.fold(
        0,
        (sum, list) => sum + list.length,
      );
      final completedCount = groupedCompletedTasks.values.fold(
        0,
        (sum, list) => sum + list.length,
      );

      if (controller.tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.currentTab.value == TabType.favorites
                    ? Icons.star_border
                    : Icons.task_alt,
                size: 64,
                color: AppColors.textSecondaryDark,
              ),
              const SizedBox(height: 16),
              Text(
                controller.currentTab.value == TabType.favorites
                    ? (settings.locale.value == 'vi'
                          ? 'Chưa có mục yêu thích'
                          : 'No favorites yet')
                    : (settings.locale.value == 'vi'
                          ? 'Chưa có công việc nào'
                          : 'No tasks yet'),
                style: TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        children: [
          if (groupedTasks.isNotEmpty)
            _buildTaskGroup(
              context,
              title: settings.locale.value == 'vi'
                  ? 'Công việc ($activeCount)'
                  : 'Tasks ($activeCount)',
              icon: Icons.list_alt,
              isExpanded: true,
              children: groupedTasks.entries.map((entry) {
                final date = entry.key;
                final dateTasks = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateGroupHeader(
                      date: date,
                      locale: settings.locale.value,
                      showLunar: settings.showLunar,
                      showSolar: settings.showSolar,
                    ),
                    ...dateTasks.map(
                      (task) => TaskItemWidget(
                        task: task,
                        locale: settings.locale.value,
                        onToggleComplete: () =>
                            controller.toggleComplete(task.id),
                        onToggleStar: () => controller.toggleStar(task.id),
                        onDelete: () => controller.deleteTask(task.id),
                        onEdit: () async {
                          final result = await Get.toNamed(
                            AppRoutes.editTask,
                            arguments: task,
                          );
                          if (result == true) {
                            controller.loadTasks();
                          }
                        },
                        onTap: () async {
                          final result = await Get.toNamed(
                            AppRoutes.editTask,
                            arguments: task,
                          );
                          if (result == true) {
                            controller.loadTasks();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          if (groupedCompletedTasks.isNotEmpty)
            _buildTaskGroup(
              context,
              title: settings.locale.value == 'vi'
                  ? 'Đã hoàn thành ($completedCount)'
                  : 'Completed ($completedCount)',
              icon: Icons.check_circle_outline,
              isExpanded: false,
              titleColor: Colors.grey,
              children: groupedCompletedTasks.entries.map((entry) {
                final date = entry.key;
                final dateTasks = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DateGroupHeader(
                      date: date,
                      locale: settings.locale.value,
                      showLunar: settings.showLunar,
                      showSolar: settings.showSolar,
                    ),
                    ...dateTasks.map(
                      (task) => TaskItemWidget(
                        task: task,
                        locale: settings.locale.value,
                        onToggleComplete: () =>
                            controller.toggleComplete(task.id),
                        onToggleStar: () => controller.toggleStar(task.id),
                        onDelete: () => controller.deleteTask(task.id),
                        onEdit: () async {
                          final result = await Get.toNamed(
                            AppRoutes.editTask,
                            arguments: task,
                          );
                          if (result == true) {
                            controller.loadTasks();
                          }
                        },
                        onTap: () async {
                          final result = await Get.toNamed(
                            AppRoutes.editTask,
                            arguments: task,
                          );
                          if (result == true) {
                            controller.loadTasks();
                          }
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
        ],
      );
    });
  }

  Widget _buildTaskGroup(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isExpanded,
    Color? titleColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (titleColor ?? AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: titleColor ?? AppColors.primary),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  titleColor ??
                  (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          children: children,
        ),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, SettingsService settings) {
    Get.dialog<Map<String, bool>>(const DeleteTasksDialog()).then((result) {
      if (result != null) {
        if (result['deleteAll'] == true) {
          controller.deleteAllTasks();
        } else if (result['deleteCompleted'] == true) {
          controller.deleteCompletedTasks();
        }
      }
    });
  }
}
