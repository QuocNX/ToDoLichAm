/// App-wide constant strings used throughout the application.
class AppStrings {
  AppStrings._();

  // App info
  static const String appName = 'ToDoLichAm';
  static const String appVersion = '1.0.0';

  // Database
  static const String taskBoxName = 'tasks';
  static const String settingsBoxName = 'settings';

  // Settings keys
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'themeMode';
  static const String keyCalendarMode = 'calendarMode';
  static const String keyFirstRun = 'isFirstRun';

  // Calendar modes
  static const String calendarModeLunar = 'lunar';
  static const String calendarModeSolar = 'solar';
  static const String calendarModeBoth = 'both';
}
