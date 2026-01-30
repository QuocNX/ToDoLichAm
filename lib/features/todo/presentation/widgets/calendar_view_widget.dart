import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/home_controller.dart';
import 'package:todo_lich_am/features/todo/presentation/widgets/task_item_widget.dart';
import 'package:lunar/lunar.dart';
import 'package:todo_lich_am/routes/app_routes.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:intl/intl.dart';

class CalendarViewWidget extends GetView<HomeController> {
  const CalendarViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final locale = settings.locale.value == 'vi' ? 'vi_VN' : 'en_US';

    return Column(
      children: [
        _buildTableCalendar(locale),
        const Divider(height: 1, thickness: 1),
        _buildLunarInfoPanel(context, locale),
        Expanded(child: _buildSelectedDayTasks(context, locale)),
      ],
    );
  }

  Widget _buildTableCalendar(String locale) {
    return Obx(
      () => TableCalendar<TaskEntity>(
        locale: locale,
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) =>
            isSameDay(controller.selectedDate.value, day),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Month'},
        eventLoader: (day) => controller.getTasksForDay(day),
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          markersMaxCount: 3,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          controller.selectedDate.value = selectedDay;
          controller.focusedDay.value = focusedDay;
        },
        onPageChanged: (focusedDay) {
          controller.focusedDay.value = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildCell(day, false),
          selectedBuilder: (context, day, focusedDay) => _buildCell(day, true),
          todayBuilder: (context, day, focusedDay) =>
              _buildCell(day, false, isToday: true),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, bool isSelected, {bool isToday = false}) {
    // Convert to Lunar
    final lunar = Lunar.fromDate(day);

    // Lunar text: "dd/mm"
    String lunarText = '${lunar.getDay()}/${lunar.getMonth()}';

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : (isToday ? AppColors.primary.withOpacity(0.2) : null),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8),
        border: isToday && !isSelected
            ? Border.all(color: AppColors.primary)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : (isToday ? AppColors.primary : null),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            lunarText,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLunarInfoPanel(BuildContext context, String locale) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;
      final lunar = Lunar.fromDate(selectedDate);

      // Solar Date Info
      final solarDateStr = DateFormat(
        'EEEE, d MMMM yyyy',
        locale,
      ).format(selectedDate);

      // Lunar Date Info
      final lunarDay = lunar.getDay();
      final lunarMonth = lunar.getMonth();
      final lunarYear = lunar.getYear();
      final canChiYear = LunarCalendarUtils.getVietnameseGanZhiYear(lunarYear);

      final lunarStr = locale == 'vi_VN'
          ? 'Âm lịch: Ngày $lunarDay tháng $lunarMonth năm $canChiYear'
          : 'Lunar: Day $lunarDay, Month $lunarMonth, Year $canChiYear';

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        width: double.infinity,
        color: Colors.grey.shade50,
        child: Column(
          children: [
            Text(
              solarDateStr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lunarStr,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSelectedDayTasks(BuildContext context, String locale) {
    return Obx(() {
      final tasks = controller.getTasksForDay(controller.selectedDate.value);

      if (tasks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                locale == 'vi_VN' ? 'Không có công việc nào' : 'No tasks',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItemWidget(
            task: task,
            locale: locale == 'vi_VN' ? 'vi' : 'en',
            onToggleComplete: () => controller.toggleTaskComplete(task),
            onToggleStar: () => controller.toggleTaskStar(task),
            onDelete: () => controller.deleteTask(task.id),
            onEdit: () async {
              final result = await Get.toNamed(
                AppRoutes.addTask,
                arguments: task,
              );
              if (result == true) {
                controller.loadTasks();
              }
            },
          );
        },
      );
    });
  }
}
