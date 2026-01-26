import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Việc cần làm'**
  String get appName;

  /// No description provided for @myTasks.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get myTasks;

  /// No description provided for @favorites.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favorites;

  /// No description provided for @newList.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách mới'**
  String get newList;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @daysRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} ngày'**
  String daysRemaining(int count);

  /// No description provided for @overdue.
  ///
  /// In vi, this message translates to:
  /// **'Quá hạn {count} ngày'**
  String overdue(int count);

  /// No description provided for @sortByDate.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp theo ngày'**
  String get sortByDate;

  /// No description provided for @sortByName.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp theo tên'**
  String get sortByName;

  /// No description provided for @addTask.
  ///
  /// In vi, this message translates to:
  /// **'Thêm công việc'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In vi, this message translates to:
  /// **'Sửa công việc'**
  String get editTask;

  /// No description provided for @taskTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get taskDescription;

  /// No description provided for @taskTitleHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tiêu đề công việc'**
  String get taskTitleHint;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mô tả (tùy chọn)'**
  String get taskDescriptionHint;

  /// No description provided for @date.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get date;

  /// No description provided for @time.
  ///
  /// In vi, this message translates to:
  /// **'Giờ'**
  String get time;

  /// No description provided for @lunarCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Âm lịch'**
  String get lunarCalendar;

  /// No description provided for @solarCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Dương lịch'**
  String get solarCalendar;

  /// No description provided for @repeat.
  ///
  /// In vi, this message translates to:
  /// **'Lặp lại'**
  String get repeat;

  /// No description provided for @noRepeat.
  ///
  /// In vi, this message translates to:
  /// **'Không lặp'**
  String get noRepeat;

  /// No description provided for @daily.
  ///
  /// In vi, this message translates to:
  /// **'Hàng ngày'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tuần'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng tháng'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In vi, this message translates to:
  /// **'Hàng năm'**
  String get yearly;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @markComplete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get markComplete;

  /// No description provided for @markIncomplete.
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn thành'**
  String get markIncomplete;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @calendarMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ lịch'**
  String get calendarMode;

  /// No description provided for @lunarOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ âm lịch'**
  String get lunarOnly;

  /// No description provided for @solarOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ dương lịch'**
  String get solarOnly;

  /// No description provided for @bothCalendars.
  ///
  /// In vi, this message translates to:
  /// **'Cả hai'**
  String get bothCalendars;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get systemMode;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get about;

  /// No description provided for @aboutApp.
  ///
  /// In vi, this message translates to:
  /// **'Về ứng dụng'**
  String get aboutApp;

  /// No description provided for @author.
  ///
  /// In vi, this message translates to:
  /// **'Tác giả'**
  String get author;

  /// No description provided for @supportAuthor.
  ///
  /// In vi, this message translates to:
  /// **'Ủng hộ tác giả'**
  String get supportAuthor;

  /// No description provided for @bankInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chuyển khoản'**
  String get bankInfo;

  /// No description provided for @bankName.
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get bankName;

  /// No description provided for @accountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số tài khoản'**
  String get accountNumber;

  /// No description provided for @accountHolder.
  ///
  /// In vi, this message translates to:
  /// **'Chủ tài khoản'**
  String get accountHolder;

  /// No description provided for @copyAccountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép STK'**
  String get copyAccountNumber;

  /// No description provided for @copied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get copied;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get version;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa công việc này?'**
  String get confirmDeleteMessage;

  /// No description provided for @taskCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành!'**
  String get taskCompleted;

  /// No description provided for @nextOccurrence.
  ///
  /// In vi, this message translates to:
  /// **'Lần tiếp theo: {date}'**
  String nextOccurrence(String date);

  /// No description provided for @noTasks.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có công việc nào'**
  String get noTasks;

  /// No description provided for @noFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mục yêu thích'**
  String get noFavorites;

  /// No description provided for @lunar.
  ///
  /// In vi, this message translates to:
  /// **'Âm'**
  String get lunar;

  /// No description provided for @solar.
  ///
  /// In vi, this message translates to:
  /// **'Dương'**
  String get solar;

  /// No description provided for @backupRestore.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu & Khôi phục'**
  String get backupRestore;

  /// No description provided for @backupData.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu dữ liệu'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục dữ liệu'**
  String get restoreData;

  /// No description provided for @backupSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Sao lưu thành công'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục thành công'**
  String get restoreSuccess;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi'**
  String get error;

  /// No description provided for @completedTasks.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get completedTasks;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
