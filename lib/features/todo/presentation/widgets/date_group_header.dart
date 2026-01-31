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

    // Prepare data
    final lunar = LunarCalendarUtils.solarToLunar(date);
    final dayOfWeek = _getDayOfWeek(date.weekday);
    final sDay = date.day.toString().padLeft(2, '0');
    final sMonth = date.month.toString().padLeft(2, '0');
    final solarStr = '$dayOfWeek, $sDay/$sMonth/${date.year}';

    final lDay = lunar.getDay().toString().padLeft(2, '0');
    final lMonth = lunar.getMonth().toString().padLeft(2, '0');
    final lYear = lunar.getYear();
    final ganZhi = LunarCalendarUtils.getVietnameseGanZhiYear(lYear);
    // Lunar string format: dd/mm/yyyy - Can Chi
    final lunarStr = '$lDay/$lMonth/$lYear - $ganZhi';

    // Relative label (Today, Yesterday, Tomorrow)
    String? relativeLabel;
    if (LunarCalendarUtils.isToday(date)) {
      relativeLabel = locale == 'vi' ? 'Hôm nay' : 'Today';
    } else if (LunarCalendarUtils.isYesterday(date)) {
      relativeLabel = locale == 'vi' ? 'Hôm qua' : 'Yesterday';
    } else if (LunarCalendarUtils.isTomorrow(date)) {
      relativeLabel = locale == 'vi' ? 'Ngày mai' : 'Tomorrow';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: Solar date
                if (showSolar)
                  Row(
                    children: [
                      const Icon(
                        Icons.wb_sunny_outlined,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        relativeLabel != null
                            ? '$relativeLabel, $solarStr'
                            : solarStr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? AppColors.primary
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                // Line 2: Lunar date
                if (showLunar)
                  Row(
                    children: [
                      const Icon(
                        Icons.nights_stay_outlined,
                        size: 16,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lunarStr,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!isToday && daysRemaining != 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daysRemaining > 0
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getDaysRemainingText(daysRemaining),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
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

  String _getDayOfWeek(int weekday) {
    if (locale == 'vi') {
      const days = [
        '',
        'Thứ 2',
        'Thứ 3',
        'Thứ 4',
        'Thứ 5',
        'Thứ 6',
        'Thứ 7',
        'Chủ Nhật',
      ];
      return days[weekday];
    } else {
      const days = [
        '',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
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
