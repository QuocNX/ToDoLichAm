import 'package:lunar/lunar.dart';

/// Utility class for Vietnamese lunar calendar operations.
class LunarCalendarUtils {
  LunarCalendarUtils._();

  /// Converts a solar (Gregorian) date to lunar date.
  static Lunar solarToLunar(DateTime solarDate) {
    final solar = Solar.fromDate(solarDate);
    return solar.getLunar();
  }

  /// Converts a lunar date to solar (Gregorian) date.
  static DateTime lunarToSolar({
    required int year,
    required int month,
    required int day,
    bool isLeapMonth = false,
  }) {
    final lunar = Lunar.fromYmd(year, month, day);
    final solar = lunar.getSolar();
    return DateTime(solar.getYear(), solar.getMonth(), solar.getDay());
  }

  /// Formats lunar date in Vietnamese format (e.g., "4/1 Âm").
  static String formatLunarDate(Lunar lunar, {bool shortFormat = false}) {
    final day = lunar.getDay();
    final month = lunar.getMonth();
    if (shortFormat) {
      return '$day/$month';
    }
    return '$day thg $month Âm';
  }

  /// Formats solar date with lunar date in Vietnamese.
  /// Returns format like "CN, 1 thg 2 (4/1)"
  static String formatDateWithLunar(
    DateTime solarDate, {
    required String locale,
    bool showLunar = true,
    bool showSolar = true,
  }) {
    final lunar = solarToLunar(solarDate);
    final dayOfWeek = _getDayOfWeekVietnamese(solarDate.weekday, locale);
    final solarStr = '$dayOfWeek, ${solarDate.day} thg ${solarDate.month}';
    final lunarStr = '${lunar.getDay()}/${lunar.getMonth()}';

    if (showLunar && showSolar) {
      return '$solarStr ($lunarStr)';
    } else if (showLunar) {
      return '$dayOfWeek, $lunarStr Âm';
    } else {
      return solarStr;
    }
  }

  /// Gets Vietnamese day of week abbreviation.
  static String _getDayOfWeekVietnamese(int weekday, String locale) {
    if (locale == 'vi') {
      const days = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return days[weekday];
    } else {
      const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[weekday];
    }
  }

  /// Checks if a date is today.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Checks if a date is yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Checks if a date is tomorrow.
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Calculates days remaining until a date.
  static int daysRemaining(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.difference(today).inDays;
  }

  /// Gets the next occurrence of a recurring task based on lunar calendar.
  static DateTime getNextLunarRecurrence({
    required DateTime currentDate,
    required String repeatType,
    int repeatInterval = 1,
  }) {
    final lunar = solarToLunar(currentDate);

    switch (repeatType) {
      case 'daily':
        return currentDate.add(Duration(days: 1 * repeatInterval));

      case 'weekly':
        return currentDate.add(Duration(days: 7 * repeatInterval));

      case 'monthly':
        // Next lunar month, same day
        var nextMonth = lunar.getMonth() + repeatInterval;
        var nextYear = lunar.getYear();
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        return lunarToSolar(
          year: nextYear,
          month: nextMonth,
          day: lunar.getDay(),
        );

      case 'yearly':
        // Next lunar year, same month and day
        return lunarToSolar(
          year: lunar.getYear() + repeatInterval,
          month: lunar.getMonth(),
          day: lunar.getDay(),
        );

      default:
        return currentDate;
    }
  }

  /// Gets the next occurrence of a recurring task based on solar calendar.
  static DateTime getNextSolarRecurrence({
    required DateTime currentDate,
    required String repeatType,
    int repeatInterval = 1,
  }) {
    switch (repeatType) {
      case 'daily':
        return currentDate.add(Duration(days: 1 * repeatInterval));

      case 'weekly':
        return currentDate.add(Duration(days: 7 * repeatInterval));

      case 'monthly':
        var nextMonth = currentDate.month + repeatInterval;
        var nextYear = currentDate.year;
        while (nextMonth > 12) {
          nextMonth -= 12;
          nextYear++;
        }
        // Handle edge case for months with fewer days
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final day = currentDate.day > daysInNextMonth
            ? daysInNextMonth
            : currentDate.day;
        return DateTime(nextYear, nextMonth, day);

      case 'yearly':
        return DateTime(
          currentDate.year + repeatInterval,
          currentDate.month,
          currentDate.day,
        );

      default:
        return currentDate;
    }
  }

  /// Gets the Vietnamese GanZhi (Can Chi) name for a lunar year.
  static String getVietnameseGanZhiYear(int year) {
    const stems = [
      'Giáp',
      'Ất',
      'Bính',
      'Đinh',
      'Mậu',
      'Kỷ',
      'Canh',
      'Tân',
      'Nhâm',
      'Quý',
    ];
    const branches = [
      'Tý',
      'Sửu',
      'Dần',
      'Mão',
      'Thìn',
      'Tỵ',
      'Ngọ',
      'Mùi',
      'Thân',
      'Dậu',
      'Tuất',
      'Hợi',
    ];

    // The year 4 AD (solar) was a Giáp Tý year in some systems,
    // but Chinese/Lunar years are cycles of 60.
    // Standard formula for lunar year name:
    final stemIndex = (year - 4) % 10;
    final branchIndex = (year - 4) % 12;

    return '${stems[stemIndex]} ${branches[branchIndex]}';
  }
}
