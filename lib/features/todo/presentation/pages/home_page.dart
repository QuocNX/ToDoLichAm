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
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(context, settings),
          _buildSortBar(context, settings),
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
            const SizedBox(width: 16),
            _buildTabItem(
              context: context,
              label: settings.locale.value == 'vi' ? 'Công việc' : 'My Tasks',
              isSelected: controller.currentTab.value == TabType.myTasks,
              onTap: () => controller.switchTab(TabType.myTasks),
            ),
            const SizedBox(width: 16),
            _buildTabItem(
              context: context,
              icon: Icons.add,
              label: settings.locale.value == 'vi'
                  ? 'Danh sách mới'
                  : 'New List',
              isSelected: false,
              onTap: () {
                // TODO: Implement new list creation
              },
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

  Widget _buildSortBar(BuildContext context, SettingsService settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Obx(
            () => Text(
              controller.currentTab.value == TabType.myTasks
                  ? (settings.locale.value == 'vi' ? 'Công việc' : 'My Tasks')
                  : (settings.locale.value == 'vi' ? 'Yêu thích' : 'Favorites'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.sort, size: 20),
            onPressed: () => _showSortMenu(context, settings),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _showSortMenu(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settings.locale.value == 'vi' ? 'Sắp xếp theo' : 'Sort by',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                settings.locale.value == 'vi' ? 'Theo ngày' : 'By date',
              ),
              trailing: Obx(
                () => controller.sortType.value == SortType.byDate
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeSortType(SortType.byDate);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: Text(
                settings.locale.value == 'vi' ? 'Theo tên' : 'By name',
              ),
              trailing: Obx(
                () => controller.sortType.value == SortType.byName
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : const SizedBox.shrink(),
              ),
              onTap: () {
                controller.changeSortType(SortType.byName);
                Navigator.pop(context);
              },
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

      final groupedTasks = controller.groupedTasks;

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: groupedTasks.length,
        itemBuilder: (context, index) {
          final date = groupedTasks.keys.elementAt(index);
          final dateTasks = groupedTasks[date]!;

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
                  onToggleComplete: () => controller.toggleComplete(task.id),
                  onToggleStar: () => controller.toggleStar(task.id),
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
        },
      );
    });
  }
}
