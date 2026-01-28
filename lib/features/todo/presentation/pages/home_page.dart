import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/home_controller.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/task_item_widget.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/date_group_header.dart';
import 'package:todo_lich_am/routes/app_routes.dart';

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
            settings.locale.value == 'vi' ? 'Việc cần làm' : 'To-Do',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Get.toNamed(AppRoutes.about),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context, settings),
          Expanded(child: _buildTaskList(context, settings)),
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
      child: Obx(
        () => Row(
          children: [
            _buildTabItem(
              context: context,
              icon: Icons.star,
              label: settings.locale.value == 'vi' ? 'Yêu thích' : 'Favorites',
              isSelected: controller.currentTab.value == TabType.favorites,
              onTap: () => controller.switchTab(TabType.favorites),
            ),
            _buildTabItem(
              context: context,
              label: settings.locale.value == 'vi' ? 'Công việc' : 'My Tasks',
              isSelected: controller.currentTab.value == TabType.myTasks,
              onTap: () => controller.switchTab(TabType.myTasks),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    IconData? icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
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
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          if (groupedTasks.isNotEmpty)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Text(
                  settings.locale.value == 'vi' ? 'Công việc' : 'Tasks',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  ...groupedTasks.entries.map((entry) {
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
                  }),
                ],
              ),
            ),
          if (groupedCompletedTasks.isNotEmpty)
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  settings.locale.value == 'vi' ? 'Đã hoàn thành' : 'Completed',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  ...groupedCompletedTasks.entries.map((entry) {
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
                  }),
                ],
              ),
            ),
        ],
      );
    });
  }
}
