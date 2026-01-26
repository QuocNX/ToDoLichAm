import 'package:flutter/material.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';

/// Widget for displaying a single task item.
class TaskItemWidget extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onToggleStar;
  final VoidCallback? onTap;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onToggleComplete,
    this.onToggleStar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)
                          : null,
                    ),
                  ),
                  if (task.time != null || task.repeatType != RepeatType.none)
                    const SizedBox(height: 4),
                  if (task.time != null || task.repeatType != RepeatType.none)
                    Row(
                      children: [
                        if (task.time != null) ...[
                          Text(
                            _formatTime(task.time!),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                        if (task.repeatType != RepeatType.none) ...[
                          if (task.time != null) const SizedBox(width: 8),
                          Icon(
                            Icons.repeat,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),

            // Star button
            GestureDetector(
              onTap: onToggleStar,
              child: Icon(
                task.isStarred ? Icons.star : Icons.star_border,
                color: task.isStarred
                    ? AppColors.star
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
