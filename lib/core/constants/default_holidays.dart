/// Default holidays for the application.
/// Contains both solar (Dương lịch) and lunar (Âm lịch) holidays.
class DefaultHolidays {
  DefaultHolidays._();

  /// Solar calendar holidays (Ngày lễ dương lịch)
  /// Format: (day, month, title_vi, title_en)
  static const List<(int, int, String, String)> solarHolidays = [
    (1, 1, 'Tết Dương lịch', "New Year's Day"),
    (14, 2, 'Ngày Lễ tình nhân', "Valentine's Day"),
    (8, 3, 'Ngày Quốc tế Phụ nữ', "International Women's Day"),
    (30, 4, 'Ngày Giải phóng miền Nam', 'Reunification Day'),
    (1, 5, 'Ngày Quốc tế Lao động', 'International Labor Day'),
    (1, 6, 'Ngày Quốc tế Thiếu nhi', "International Children's Day"),
    (27, 7, 'Ngày Thương binh Liệt sĩ', 'War Invalids and Martyrs Day'),
    (2, 9, 'Quốc khánh Việt Nam', 'Vietnam National Day'),
    (20, 10, 'Ngày Phụ nữ Việt Nam', 'Vietnamese Women Day'),
    (20, 11, 'Ngày Nhà giáo Việt Nam', 'Vietnamese Teachers Day'),
    (22, 12, 'Ngày Quân đội nhân dân Việt Nam', 'Vietnam People\'s Army Day'),
    (24, 12, 'Đêm Giáng sinh', 'Christmas Eve'),
    (25, 12, 'Lễ Giáng sinh', 'Christmas Day'),
  ];

  /// Lunar calendar holidays (Ngày lễ âm lịch)
  /// Format: (day, month, title_vi, title_en)
  static const List<(int, int, String, String)> lunarHolidays = [
    (1, 1, 'Mùng 1 Tết Nguyên Đán', 'Lunar New Year Day 1'),
    (2, 1, 'Mùng 2 Tết Nguyên Đán', 'Lunar New Year Day 2'),
    (3, 1, 'Mùng 3 Tết Nguyên Đán', 'Lunar New Year Day 3'),
    (15, 1, 'Tết Nguyên tiêu (Rằm tháng Giêng)', 'Lantern Festival'),
    (3, 3, 'Tết Hàn thực', 'Cold Food Festival'),
    (10, 3, 'Giỗ Tổ Hùng Vương', 'Hung Kings Commemoration'),
    (15, 4, 'Lễ Phật Đản', "Buddha's Birthday"),
    (5, 5, 'Tết Đoan Ngọ', 'Dragon Boat Festival'),
    (15, 7, 'Lễ Vu Lan - Rằm tháng 7', 'Ghost Festival'),
    (15, 8, 'Tết Trung Thu', 'Mid-Autumn Festival'),
    (23, 12, 'Ngày Ông Công, Ông Táo', 'Kitchen God Day'),
    (30, 12, 'Đêm Giao thừa', "New Year's Eve"),
  ];
}
