// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Việc cần làm';

  @override
  String get myTasks => 'Công việc';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get newList => 'Danh sách mới';

  @override
  String get today => 'Hôm nay';

  @override
  String daysRemaining(int count) {
    return 'Còn $count ngày';
  }

  @override
  String overdue(int count) {
    return 'Quá hạn $count ngày';
  }

  @override
  String get sortByDate => 'Sắp xếp theo ngày';

  @override
  String get sortByName => 'Sắp xếp theo tên';

  @override
  String get addTask => 'Thêm công việc';

  @override
  String get editTask => 'Sửa công việc';

  @override
  String get taskTitle => 'Tiêu đề';

  @override
  String get taskDescription => 'Mô tả';

  @override
  String get taskTitleHint => 'Nhập tiêu đề công việc';

  @override
  String get taskDescriptionHint => 'Nhập mô tả (tùy chọn)';

  @override
  String get date => 'Ngày';

  @override
  String get time => 'Giờ';

  @override
  String get lunarCalendar => 'Âm lịch';

  @override
  String get solarCalendar => 'Dương lịch';

  @override
  String get repeat => 'Lặp lại';

  @override
  String get noRepeat => 'Không lặp';

  @override
  String get daily => 'Hàng ngày';

  @override
  String get weekly => 'Hàng tuần';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get yearly => 'Hàng năm';

  @override
  String get save => 'Lưu';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get markComplete => 'Hoàn thành';

  @override
  String get markIncomplete => 'Chưa hoàn thành';

  @override
  String get settings => 'Cài đặt';

  @override
  String get calendarMode => 'Chế độ lịch';

  @override
  String get lunarOnly => 'Chỉ âm lịch';

  @override
  String get solarOnly => 'Chỉ dương lịch';

  @override
  String get bothCalendars => 'Cả hai';

  @override
  String get theme => 'Giao diện';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get systemMode => 'Theo hệ thống';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Thông báo';

  @override
  String get about => 'Thông tin';

  @override
  String get aboutApp => 'Về ứng dụng';

  @override
  String get author => 'Tác giả';

  @override
  String get supportAuthor => 'Ủng hộ tác giả';

  @override
  String get bankInfo => 'Thông tin chuyển khoản';

  @override
  String get bankName => 'Ngân hàng';

  @override
  String get accountNumber => 'Số tài khoản';

  @override
  String get accountHolder => 'Chủ tài khoản';

  @override
  String get copyAccountNumber => 'Sao chép STK';

  @override
  String get copied => 'Đã sao chép';

  @override
  String get version => 'Phiên bản';

  @override
  String get confirmDelete => 'Xác nhận xóa?';

  @override
  String get confirmDeleteMessage => 'Bạn có chắc muốn xóa công việc này?';

  @override
  String get taskCompleted => 'Đã hoàn thành!';

  @override
  String nextOccurrence(String date) {
    return 'Lần tiếp theo: $date';
  }

  @override
  String get noTasks => 'Chưa có công việc nào';

  @override
  String get noFavorites => 'Chưa có mục yêu thích';

  @override
  String get lunar => 'Âm';

  @override
  String get solar => 'Dương';

  @override
  String get backupRestore => 'Sao lưu & Khôi phục';

  @override
  String get backupData => 'Sao lưu dữ liệu';

  @override
  String get restoreData => 'Khôi phục dữ liệu';

  @override
  String get backupSuccess => 'Sao lưu thành công';

  @override
  String get restoreSuccess => 'Khôi phục thành công';

  @override
  String get error => 'Lỗi';

  @override
  String get completedTasks => 'Đã hoàn thành';
}
