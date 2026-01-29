import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';
import 'package:todo_lich_am/core/constants/default_holidays.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

/// Service to handle first run logic and add default holidays.
class FirstRunService extends GetxService {
  late Box _settingsBox;

  /// Initializes the first run service.
  Future<FirstRunService> init() async {
    _settingsBox = await Hive.openBox(AppStrings.settingsBoxName);
    return this;
  }

  /// Checks if this is the first time the app is running.
  bool get isFirstRun {
    return _settingsBox.get(AppStrings.keyFirstRun, defaultValue: true);
  }

  /// Marks first run as completed.
  Future<void> markFirstRunComplete() async {
    await _settingsBox.put(AppStrings.keyFirstRun, false);
  }

  /// Adds solar holidays as tasks.
  Future<void> addSolarHolidays(
    TaskRepository repository,
    String locale,
  ) async {
    final now = DateTime.now();
    final currentYear = now.year;

    final List<TaskEntity> tasksToAdd = [];
    for (final holiday in DefaultHolidays.solarHolidays) {
      final day = holiday.$1;
      final month = holiday.$2;
      final titleVi = holiday.$3;
      final titleEn = holiday.$4;

      // Calculate due date for current year or next year if already passed
      var dueDate = DateTime(currentYear, month, day);
      if (dueDate.isBefore(now)) {
        dueDate = DateTime(currentYear + 1, month, day);
      }

      tasksToAdd.add(
        TaskEntity(
          id: const Uuid().v4(),
          title: locale == 'vi' ? titleVi : titleEn,
          description: locale == 'vi'
              ? 'Ngày lễ dương lịch - $day/$month'
              : 'Solar holiday - $day/$month',
          dueDate: dueDate,
          isLunarCalendar: false,
          repeatType: RepeatType.yearly,
          repeatInterval: 1,
          isCompleted: false,
          isStarred: false,
          category: 'holiday',
          createdAt: DateTime.now(),
        ),
      );
    }
    await repository.addAllTasks(tasksToAdd);
  }

  /// Adds lunar holidays as tasks.
  Future<void> addLunarHolidays(
    TaskRepository repository,
    String locale,
  ) async {
    final now = DateTime.now();

    final List<TaskEntity> tasksToAdd = [];
    for (final holiday in DefaultHolidays.lunarHolidays) {
      final day = holiday.$1;
      final month = holiday.$2;
      final titleVi = holiday.$3;
      final titleEn = holiday.$4;

      try {
        // Convert lunar date to solar date
        DateTime solarDate;
        try {
          solarDate = LunarCalendarUtils.lunarToSolar(
            day: day,
            month: month,
            year: now.year,
            isLeapMonth: false,
          );
        } catch (e) {
          // Try next year if current year's date is invalid
          solarDate = LunarCalendarUtils.lunarToSolar(
            day: day,
            month: month,
            year: now.year + 1,
            isLeapMonth: false,
          );
        }

        // Calculate due date for current year or next year if already passed
        var dueDate = solarDate;
        if (dueDate.isBefore(now)) {
          try {
            dueDate = LunarCalendarUtils.lunarToSolar(
              day: day,
              month: month,
              year: now.year + 1,
              isLeapMonth: false,
            );
          } catch (e) {
            // If next year also fails, try year after
            dueDate = LunarCalendarUtils.lunarToSolar(
              day: day,
              month: month,
              year: now.year + 2,
              isLeapMonth: false,
            );
          }
        }

        tasksToAdd.add(
          TaskEntity(
            id: const Uuid().v4(),
            title: locale == 'vi' ? titleVi : titleEn,
            description: locale == 'vi'
                ? 'Ngày lễ âm lịch - $day/$month âm lịch'
                : 'Lunar holiday - $day/$month lunar',
            dueDate: dueDate,
            isLunarCalendar: true,
            lunarDay: day,
            lunarMonth: month,
            lunarYear: dueDate.year,
            repeatType: RepeatType.yearly,
            repeatInterval: 1,
            isCompleted: false,
            isStarred: false,
            category: 'holiday',
            createdAt: DateTime.now(),
          ),
        );
      } catch (e) {
        // Skip this holiday if conversion fails for all attempts
        debugPrint('Skipping lunar holiday $day/$month: $e');
      }
    }
    await repository.addAllTasks(tasksToAdd);
  }
}
