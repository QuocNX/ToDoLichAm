import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';

/// Page for displaying task details.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Get.arguments as TaskEntity;
    final settings = Get.find<SettingsService>();
    final isVi = settings.locale.value == 'vi';
    final lunar = LunarCalendarUtils.solarToLunar(task.dueDate);

    return Scaffold(
      appBar: AppBar(title: Text(isVi ? 'Chi tiết' : 'Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Description
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text(
                task.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Date info card
            _buildInfoCard(
              context: context,
              icon: Icons.calendar_today,
              title: isVi ? 'Ngày' : 'Date',
              children: [
                _buildInfoRow(
                  isVi ? 'Dương lịch' : 'Solar',
                  '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                ),
                _buildInfoRow(
                  isVi ? 'Âm lịch' : 'Lunar',
                  '${lunar.getDay()}/${lunar.getMonth()}/${lunar.getYear()}',
                ),
                if (task.time != null)
                  _buildInfoRow(
                    isVi ? 'Giờ' : 'Time',
                    '${task.time!.hour.toString().padLeft(2, '0')}:${task.time!.minute.toString().padLeft(2, '0')}',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Repeat info
            if (task.repeatType != RepeatType.none)
              _buildInfoCard(
                context: context,
                icon: Icons.repeat,
                title: isVi ? 'Lặp lại' : 'Repeat',
                children: [
                  _buildInfoRow(
                    isVi ? 'Loại' : 'Type',
                    _getRepeatTypeText(task.repeatType, isVi),
                  ),
                  _buildInfoRow(
                    isVi ? 'Theo lịch' : 'Calendar',
                    task.isLunarCalendar
                        ? (isVi ? 'Âm lịch' : 'Lunar')
                        : (isVi ? 'Dương lịch' : 'Solar'),
                  ),
                ],
              ),

            // Status
            const SizedBox(height: 16),
            _buildInfoCard(
              context: context,
              icon: task.isCompleted ? Icons.check_circle : Icons.pending,
              title: isVi ? 'Trạng thái' : 'Status',
              children: [
                _buildInfoRow(
                  isVi ? 'Hoàn thành' : 'Completed',
                  task.isCompleted
                      ? (isVi ? 'Đã hoàn thành' : 'Yes')
                      : (isVi ? 'Chưa hoàn thành' : 'No'),
                ),
                if (task.isStarred)
                  _buildInfoRow(isVi ? 'Yêu thích' : 'Favorite', '⭐'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getRepeatTypeText(RepeatType type, bool isVi) {
    switch (type) {
      case RepeatType.daily:
        return isVi ? 'Hàng ngày' : 'Daily';
      case RepeatType.weekly:
        return isVi ? 'Hàng tuần' : 'Weekly';
      case RepeatType.monthly:
        return isVi ? 'Hàng tháng' : 'Monthly';
      case RepeatType.yearly:
        return isVi ? 'Hàng năm' : 'Yearly';
      default:
        return isVi ? 'Không lặp' : 'No repeat';
    }
  }
}
