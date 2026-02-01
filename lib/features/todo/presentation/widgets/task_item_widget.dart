import 'package:flutter/material.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

/// Widget for displaying a single task item with swipe and long press actions.
class TaskItemWidget extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onToggleStar;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final String locale;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onToggleComplete,
    this.onToggleStar,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.locale = 'vi',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(task.id),
      background: _buildSwipeBackground(
        alignment: Alignment.centerLeft,
        color: AppColors.primary,
        icon: task.isCompleted ? Icons.undo : Icons.check_circle,
        label: task.isCompleted
            ? (locale == 'vi' ? 'Hoàn tác' : 'Undo')
            : (locale == 'vi' ? 'Hoàn thành' : 'Complete'),
      ),
      secondaryBackground: _buildSwipeBackground(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        icon: Icons.delete,
        label: locale == 'vi' ? 'Xóa' : 'Delete',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Toggle complete
          onToggleComplete?.call();
          return false; // Don't dismiss, just toggle
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left: Delete with confirmation
          return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptionsMenu(context),
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
                    // Icon + Task title inline
                    Row(
                      children: [
                        Icon(
                          task.isLunarCalendar
                              ? Icons.nights_stay_outlined
                              : Icons.wb_sunny_outlined,
                          size: 16,
                          color: task.isLunarCalendar
                              ? Colors.indigo
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
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
                        ),
                      ],
                    ),
                    // Time and repeat info
                    if (task.time != null || task.repeatType != RepeatType.none)
                      const SizedBox(height: 4),
                    if (task.time != null || task.repeatType != RepeatType.none)
                      Row(
                        children: [
                          if (task.time != null) ...[
                            Text(
                              _formatTime(task.time!),
                              style: TextStyle(
                                fontSize: 13,
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
                            const SizedBox(width: 4),
                            Text(
                              '${locale == 'vi' ? 'Lặp lại: ' : 'Repeat: '}${_getRepeatText(task)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    // Scheduled date for completed tasks
                    if (task.isCompleted && task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getScheduledDateText(task.dueDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white),
              ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale == 'vi' ? 'Xác nhận xóa' : 'Confirm Delete'),
            content: Text(
              locale == 'vi'
                  ? 'Bạn có chắc muốn xóa công việc này?'
                  : 'Are you sure you want to delete this task?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(locale == 'vi' ? 'Hủy' : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(locale == 'vi' ? 'Xóa' : 'Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showOptionsMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Task title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Divider(),
              // Options
              _buildOptionItem(
                context: context,
                icon: task.isCompleted ? Icons.undo : Icons.check_circle,
                label: task.isCompleted
                    ? (locale == 'vi'
                          ? 'Đánh dấu chưa hoàn thành'
                          : 'Mark as incomplete')
                    : (locale == 'vi'
                          ? 'Đánh dấu hoàn thành'
                          : 'Mark as complete'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleComplete?.call();
                },
              ),
              _buildOptionItem(
                context: context,
                icon: task.isStarred ? Icons.star_border : Icons.star,
                label: task.isStarred
                    ? (locale == 'vi'
                          ? 'Bỏ yêu thích'
                          : 'Remove from favorites')
                    : (locale == 'vi'
                          ? 'Thêm vào yêu thích'
                          : 'Add to favorites'),
                iconColor: task.isStarred ? null : AppColors.star,
                onTap: () {
                  Navigator.pop(context);
                  onToggleStar?.call();
                },
              ),
              _buildOptionItem(
                context: context,
                icon: Icons.edit,
                label: locale == 'vi' ? 'Chỉnh sửa' : 'Edit',
                onTap: () {
                  Navigator.pop(context);
                  onEdit?.call();
                },
              ),
              _buildOptionItem(
                context: context,
                icon: Icons.delete,
                label: locale == 'vi' ? 'Xóa' : 'Delete',
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await _showDeleteConfirmation(context);
                  if (confirmed) {
                    onDelete?.call();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getRepeatText(TaskEntity task) {
    if (task.dueDate == null && task.repeatWeekDays == null) return '';

    if (task.repeatInterval <= 1) {
      switch (task.repeatType) {
        case RepeatType.daily:
          return locale == 'vi' ? 'Hàng ngày' : 'Daily';
        case RepeatType.weekly:
          String daysText;
          if (task.repeatWeekDays != null && task.repeatWeekDays!.isNotEmpty) {
            final days = task.repeatWeekDays!..sort();
            daysText = days.map((day) => _getDayName(day)).join(', ');
          } else if (task.dueDate != null) {
            daysText = DateFormat('EEEE', locale).format(task.dueDate!);
          } else {
            daysText = '';
          }
          return locale == 'vi'
              ? 'Hàng tuần vào $daysText'
              : 'Weekly on $daysText';
        case RepeatType.monthly:
          if (task.isLunarCalendar) {
            final day =
                task.lunarDay ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getDay()
                    : 1);
            return locale == 'vi'
                ? 'Hàng tháng vào ngày $day Âm lịch'
                : 'Monthly on lunar day $day';
          } else {
            final day = task.dueDate?.day ?? 1;
            return locale == 'vi'
                ? 'Hàng tháng vào ngày $day'
                : 'Monthly on day $day';
          }
        case RepeatType.yearly:
          if (task.isLunarCalendar) {
            final day =
                task.lunarDay ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getDay()
                    : 1);
            final month =
                task.lunarMonth ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getMonth()
                    : 1);
            return locale == 'vi'
                ? 'Hàng năm vào $day/$month Âm lịch'
                : 'Yearly on lunar $day/$month';
          } else {
            final day = task.dueDate?.day ?? 1;
            final month = task.dueDate?.month ?? 1;
            return locale == 'vi'
                ? 'Hàng năm vào $day/$month'
                : 'Yearly on $day/$month';
          }
        case RepeatType.none:
          return '';
      }
    } else {
      switch (task.repeatType) {
        case RepeatType.daily:
          return locale == 'vi'
              ? 'Mỗi ${task.repeatInterval} ngày'
              : 'Every ${task.repeatInterval} days';
        case RepeatType.weekly:
          String daysText;
          if (task.repeatWeekDays != null && task.repeatWeekDays!.isNotEmpty) {
            final days = task.repeatWeekDays!..sort();
            daysText = days.map((day) => _getDayName(day)).join(', ');
          } else if (task.dueDate != null) {
            daysText = DateFormat('EEEE', locale).format(task.dueDate!);
          } else {
            daysText = '';
          }
          return locale == 'vi'
              ? 'Mỗi ${task.repeatInterval} tuần vào $daysText'
              : 'Every ${task.repeatInterval} weeks on $daysText';
        case RepeatType.monthly:
          if (task.isLunarCalendar) {
            final day =
                task.lunarDay ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getDay()
                    : 1);
            return locale == 'vi'
                ? 'Mỗi ${task.repeatInterval} tháng vào ngày $day Âm lịch'
                : 'Every ${task.repeatInterval} months on lunar day $day';
          }
          final day = task.dueDate?.day ?? 1;
          return locale == 'vi'
              ? 'Mỗi ${task.repeatInterval} tháng vào ngày $day'
              : 'Every ${task.repeatInterval} months on day $day';
        case RepeatType.yearly:
          if (task.isLunarCalendar) {
            final day =
                task.lunarDay ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getDay()
                    : 1);
            final month =
                task.lunarMonth ??
                (task.dueDate != null
                    ? LunarCalendarUtils.solarToLunar(task.dueDate!).getMonth()
                    : 1);
            return locale == 'vi'
                ? 'Mỗi ${task.repeatInterval} năm vào $day/$month Âm lịch'
                : 'Every ${task.repeatInterval} years on lunar $day/$month';
          }
          final day = task.dueDate?.day ?? 1;
          final month = task.dueDate?.month ?? 1;
          return locale == 'vi'
              ? 'Mỗi ${task.repeatInterval} năm vào $day/$month'
              : 'Every ${task.repeatInterval} years on $day/$month';
        case RepeatType.none:
          return '';
      }
    }
  }

  String _getDayName(int weekday) {
    if (locale == 'vi') {
      // User said: "thứ 6, 7, CN".
      // Let's try to match:
      switch (weekday) {
        case 1:
          return 'Thứ 2';
        case 2:
          return 'Thứ 3';
        case 3:
          return 'Thứ 4';
        case 4:
          return 'Thứ 5';
        case 5:
          return 'Thứ 6';
        case 6:
          return 'Thứ 7';
        case 7:
          return 'CN';
        default:
          return '';
      }
    } else {
      // English
      switch (weekday) {
        case 1:
          return 'Mon';
        case 2:
          return 'Tue';
        case 3:
          return 'Wed';
        case 4:
          return 'Thu';
        case 5:
          return 'Fri';
        case 6:
          return 'Sat';
        case 7:
          return 'Sun';
        default:
          return '';
      }
    }
  }

  String _getScheduledDateText(DateTime date) {
    final dayOfWeek = _getDayName(date.weekday);
    if (task.isLunarCalendar) {
      final lunar = LunarCalendarUtils.solarToLunar(date);
      final day = lunar.getDay().toString().padLeft(2, '0');
      final month = lunar.getMonth().toString().padLeft(2, '0');
      final year = lunar.getYear();
      final ganZhi = LunarCalendarUtils.getVietnameseGanZhiYear(year);
      return '$dayOfWeek, $day/$month/$year - $ganZhi';
    } else {
      return '$dayOfWeek, ${DateFormat('dd/MM/yyyy').format(date)}';
    }
  }
}
