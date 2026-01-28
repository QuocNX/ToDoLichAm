import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';

/// A custom lunar date picker using Cupertino-style pickers.
class LunarDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateChanged;
  final String locale;

  const LunarDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
    this.locale = 'vi',
  });

  @override
  State<LunarDatePicker> createState() => _LunarDatePickerState();
}

class _LunarDatePickerState extends State<LunarDatePicker> {
  late int _selectedYear;
  late int
  _selectedMonth; // 1-12, or negative for leap month (e.g., -4 for leap month 4)
  late int _selectedDay;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  final List<int> _years = List.generate(201, (index) => 1900 + index);
  List<int> _months = [];
  List<int> _days = [];

  @override
  void initState() {
    super.initState();
    final lunar = Solar.fromDate(widget.initialDate).getLunar();
    _selectedYear = lunar.getYear();
    _selectedMonth = lunar.getMonth();
    if (lunar.getMonth() < 0) {
      _selectedMonth = -_selectedMonth;
    }
    _selectedDay = lunar.getDay();

    _yearController = FixedExtentScrollController(
      initialItem: _years.indexOf(_selectedYear),
    );

    _updateMonths();
    _monthController = FixedExtentScrollController(
      initialItem: _months.indexOf(_selectedMonth),
    );

    _updateDays();
    _dayController = FixedExtentScrollController(
      initialItem: _days.indexOf(_selectedDay),
    );
  }

  void _updateMonths() {
    final lunarYear = LunarYear.fromYear(_selectedYear);
    final leapMonth = lunarYear.getLeapMonth();

    _months = [];
    for (int i = 1; i <= 12; i++) {
      _months.add(i);
      if (i == leapMonth) {
        _months.add(-i); // Use negative to represent leap month
      }
    }
  }

  void _updateDays() {
    final isLeap = _selectedMonth < 0;
    final month = _selectedMonth.abs();
    // To get month length, we can use LunarMonth.
    // In lunar-dart, LunarMonth.fromYm takes (year, month).
    // If month is negative, it's a leap month.
    final lunarMonth = LunarMonth.fromYm(
      _selectedYear,
      isLeap ? -month : month,
    );
    final dayCount = lunarMonth?.getDayCount() ?? 30;

    _days = List.generate(dayCount, (index) => index + 1);

    if (_selectedDay > dayCount) {
      _selectedDay = dayCount;
      _dayController.jumpToItem(_days.indexOf(_selectedDay));
    }
  }

  void _onDateChanged() {
    final isLeap = _selectedMonth < 0;
    final month = _selectedMonth.abs();

    try {
      final lunar = Lunar.fromYmd(
        _selectedYear,
        isLeap ? -month : month,
        _selectedDay,
      );
      final solar = lunar.getSolar();
      final solarDate = DateTime(
        solar.getYear(),
        solar.getMonth(),
        solar.getDay(),
      );
      widget.onDateChanged(solarDate);
    } catch (e) {
      // Handle invalid lunar date if any
    }
  }

  String _getMonthText(int month) {
    if (month < 0) {
      return widget.locale == 'vi'
          ? 'Tháng ${month.abs()} (nhuận)'
          : 'Month ${month.abs()} (Leap)';
    }
    return widget.locale == 'vi' ? 'Tháng $month' : 'Month $month';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 300,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Row(
              children: [
                // Day Picker
                Expanded(
                  flex: 2,
                  child: _buildPicker(
                    controller: _dayController,
                    items: _days.map((d) => 'Ngày $d').toList(),
                    onChanged: (index) {
                      setState(() {
                        _selectedDay = _days[index];
                        _onDateChanged();
                      });
                    },
                  ),
                ),
                // Month Picker
                Expanded(
                  flex: 3,
                  child: _buildPicker(
                    controller: _monthController,
                    items: _months.map((m) => _getMonthText(m)).toList(),
                    onChanged: (index) {
                      setState(() {
                        _selectedMonth = _months[index];
                        _updateDays();
                        _onDateChanged();
                      });
                    },
                  ),
                ),
                // Year Picker
                Expanded(
                  flex: 2,
                  child: _buildPicker(
                    controller: _yearController,
                    items: _years.map((y) => 'Năm $y').toList(),
                    onChanged: (index) {
                      setState(() {
                        _selectedYear = _years[index];
                        _updateMonths();
                        _updateDays();
                        _onDateChanged();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.locale == 'vi' ? 'Hủy' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            widget.locale == 'vi' ? 'Chọn ngày âm lịch' : 'Select Lunar Date',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              widget.locale == 'vi' ? 'Xong' : 'Done',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<String> items,
    required ValueChanged<int> onChanged,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 40,
      onSelectedItemChanged: onChanged,
      children: items.map((item) {
        return Center(child: Text(item, style: const TextStyle(fontSize: 16)));
      }).toList(),
    );
  }
}
