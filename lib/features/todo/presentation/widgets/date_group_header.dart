import 'package:flutter/material.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';

/// Header widget for date groups in task list.
class DateGroupHeader extends StatelessWidget {
  final DateTime date;
  final String locale;
  final bool showLunar;
  final bool showSolar;

  const DateGroupHeader({
    super.key,
    required this.date,
    required this.locale,
    this.showLunar = true,
    this.showSolar = true,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = LunarCalendarUtils.isToday(date);
    final daysRemaining = LunarCalendarUtils.daysRemaining(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDateText(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isToday
                        ? AppColors.primary
                        : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                ),
              ],
            ),
          ),
          if (!isToday && daysRemaining != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysRemaining > 0
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getDaysRemainingText(daysRemaining),
                style: TextStyle(
                  fontSize: 12,
                  color: daysRemaining > 0
                      ? AppColors.primary
                      : AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getDateText() {
    String? relativeLabel;
    if (LunarCalendarUtils.isToday(date)) {
      relativeLabel = locale == 'vi' ? 'Hôm nay' : 'Today';
    } else if (LunarCalendarUtils.isYesterday(date)) {
      relativeLabel = locale == 'vi' ? 'Hôm qua' : 'Yesterday';
    } else if (LunarCalendarUtils.isTomorrow(date)) {
      relativeLabel = locale == 'vi' ? 'Ngày mai' : 'Tomorrow';
    }

    final lunar = LunarCalendarUtils.solarToLunar(date);
    final dayOfWeek = _getDayOfWeek(date.weekday);

    final sDay = date.day.toString().padLeft(2, '0');
    final sMonth = date.month.toString().padLeft(2, '0');
    final solarStr = '$dayOfWeek, $sDay/$sMonth/${date.year}';

    final lDay = lunar.getDay().toString().padLeft(2, '0');
    final lMonth = lunar.getMonth().toString().padLeft(2, '0');
    final lYear = lunar.getYear();
    final ganZhi = LunarCalendarUtils.getVietnameseGanZhiYear(lYear);
    final lunarStr = '$lDay/$lMonth/$lYear - $ganZhi';

    String dateStr;
    if (showLunar && showSolar) {
      dateStr = '$solarStr ($lunarStr)';
    } else if (showLunar) {
      dateStr = '$dayOfWeek, $lunarStr Âm';
    } else {
      dateStr = solarStr;
    }

    return relativeLabel != null ? '$relativeLabel, $dateStr' : dateStr;
  }

  String _getDayOfWeek(int weekday) {
    if (locale == 'vi') {
      const days = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return days[weekday];
    } else {
      const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[weekday];
    }
  }

  String _getDaysRemainingText(int days) {
    if (days > 0) {
      return locale == 'vi' ? 'Còn $days ngày' : '$days days left';
    } else {
      return locale == 'vi' ? 'Quá hạn ${-days} ngày' : '${-days} days overdue';
    }
  }
}
