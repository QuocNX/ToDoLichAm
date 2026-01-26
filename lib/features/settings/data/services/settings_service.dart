import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';

/// Service for managing app settings using Hive.
class SettingsService extends GetxService {
  late Box _settingsBox;

  // Observable settings
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString calendarMode = AppStrings.calendarModeBoth.obs;
  final RxString locale = 'vi'.obs;

  /// Initializes the service asynchronously.
  Future<SettingsService> init() async {
    await _loadSettings();
    return this;
  }

  Future<void> _loadSettings() async {
    try {
      _settingsBox = await Hive.openBox(AppStrings.settingsBoxName);
    } catch (e) {
      // Fallback or handle error if needed
      debugPrint('Error opening settings box: $e');
      // Re-throw or proceed with defaults if box failed?
      // For now, let's assume it works or we might need to delete bad box.
      return;
    }

    // Load theme mode
    final savedTheme = _settingsBox.get(
      AppStrings.keyThemeMode,
      defaultValue: 'system',
    );
    themeMode.value = _themeModeFromString(savedTheme);

    // Load calendar mode
    calendarMode.value = _settingsBox.get(
      AppStrings.keyCalendarMode,
      defaultValue: AppStrings.calendarModeBoth,
    );

    // Load locale
    locale.value = _settingsBox.get(AppStrings.keyLocale, defaultValue: 'vi');
  }

  /// Sets the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _settingsBox.put(AppStrings.keyThemeMode, _themeModeToString(mode));
    Get.changeThemeMode(mode);
  }

  /// Sets the calendar mode (lunar, solar, or both)
  Future<void> setCalendarMode(String mode) async {
    calendarMode.value = mode;
    await _settingsBox.put(AppStrings.keyCalendarMode, mode);
  }

  /// Sets the locale
  Future<void> setLocale(String localeCode) async {
    locale.value = localeCode;
    await _settingsBox.put(AppStrings.keyLocale, localeCode);
    Get.updateLocale(Locale(localeCode));
  }

  /// Whether to show lunar calendar
  bool get showLunar =>
      calendarMode.value == AppStrings.calendarModeLunar ||
      calendarMode.value == AppStrings.calendarModeBoth;

  /// Whether to show solar calendar
  bool get showSolar =>
      calendarMode.value == AppStrings.calendarModeSolar ||
      calendarMode.value == AppStrings.calendarModeBoth;

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
