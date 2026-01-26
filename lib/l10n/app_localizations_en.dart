// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'To-Do';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get favorites => 'Favorites';

  @override
  String get newList => 'New List';

  @override
  String get today => 'Today';

  @override
  String daysRemaining(int count) {
    return '$count days left';
  }

  @override
  String overdue(int count) {
    return '$count days overdue';
  }

  @override
  String get sortByDate => 'Sort by date';

  @override
  String get sortByName => 'Sort by name';

  @override
  String get addTask => 'Add task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskTitleHint => 'Enter task title';

  @override
  String get taskDescriptionHint => 'Enter description (optional)';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get lunarCalendar => 'Lunar calendar';

  @override
  String get solarCalendar => 'Solar calendar';

  @override
  String get repeat => 'Repeat';

  @override
  String get noRepeat => 'No repeat';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get markComplete => 'Mark complete';

  @override
  String get markIncomplete => 'Mark incomplete';

  @override
  String get settings => 'Settings';

  @override
  String get calendarMode => 'Calendar mode';

  @override
  String get lunarOnly => 'Lunar only';

  @override
  String get solarOnly => 'Solar only';

  @override
  String get bothCalendars => 'Both';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get systemMode => 'System';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get about => 'About';

  @override
  String get aboutApp => 'About app';

  @override
  String get author => 'Author';

  @override
  String get supportAuthor => 'Support author';

  @override
  String get bankInfo => 'Bank transfer info';

  @override
  String get bankName => 'Bank';

  @override
  String get accountNumber => 'Account number';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get copyAccountNumber => 'Copy account number';

  @override
  String get copied => 'Copied';

  @override
  String get version => 'Version';

  @override
  String get confirmDelete => 'Confirm delete?';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this task?';

  @override
  String get taskCompleted => 'Completed!';

  @override
  String nextOccurrence(String date) {
    return 'Next: $date';
  }

  @override
  String get noTasks => 'No tasks yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get lunar => 'Lunar';

  @override
  String get solar => 'Solar';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backupData => 'Backup data';

  @override
  String get restoreData => 'Restore data';

  @override
  String get backupSuccess => 'Backup successful';

  @override
  String get restoreSuccess => 'Restore successful';

  @override
  String get error => 'Error';

  @override
  String get completedTasks => 'Completed';
}
