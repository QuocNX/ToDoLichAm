import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/add_task_controller.dart';

/// Page for adding or editing a task.
class AddTaskPage extends GetView<AddTaskController> {
  const AddTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final isVi = settings.locale.value == 'vi';

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final isVi = Get.find<SettingsService>().locale.value == 'vi';
          return Text(
            controller.isEditing
                ? (isVi ? 'Sửa công việc' : 'Edit task')
                : (isVi ? 'Thêm công việc' : 'Add task'),
          );
        }),
        actions: [
          if (controller.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: controller.deleteTask,
            ),
          // Save button in AppBar
          Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save, color: AppColors.primary),
                    onPressed: controller.saveTask,
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () => IgnorePointer(
              ignoring: controller.isCompleted.value,
              child: Column(
                children: [
                  // 1. Title Input (Always visible, autofocus)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: TextField(
                      controller: controller.titleController,
                      autofocus: !controller.isEditing,
                      decoration: InputDecoration(
                        hintText: isVi
                            ? 'Nhập tiêu đề công việc'
                            : 'Enter task title',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => controller.saveTask(),
                    ),
                  ),

                  // 3. Expandable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Obx(() {
                            if (controller.isDescriptionVisible.value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller:
                                        controller.descriptionController,
                                    decoration: InputDecoration(
                                      hintText: isVi
                                          ? 'Nhập mô tả chi tiết'
                                          : 'Enter details',
                                      border: const OutlineInputBorder(),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                    maxLines: 3,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          // Schedule Section
                          Obx(() {
                            if (controller.isScheduleVisible.value) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Calendar type toggle
                                  _buildLabel(
                                    isVi ? 'Loại lịch' : 'Calendar type',
                                  ),
                                  const SizedBox(height: 8),
                                  _buildCalendarToggle(context, isVi),
                                  const SizedBox(height: 20),

                                  // Date selector
                                  _buildLabel(isVi ? 'Ngày' : 'Date'),
                                  const SizedBox(height: 8),
                                  _buildDateSelector(context, isVi),
                                  const SizedBox(height: 20),

                                  // Time selector
                                  _buildLabel(isVi ? 'Giờ' : 'Time'),
                                  const SizedBox(height: 8),
                                  _buildTimeSelector(context, isVi),
                                  const SizedBox(height: 20),

                                  // Repeat selector
                                  _buildLabel(isVi ? 'Lặp lại' : 'Repeat'),
                                  const SizedBox(height: 8),
                                  _buildRepeatSelector(context, isVi),
                                  const SizedBox(height: 20),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 8),

                          // Toolbar (Moved here)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Description Toggle
                                Obx(
                                  () => IconButton(
                                    icon: Icon(
                                      Icons.description_outlined,
                                      color:
                                          controller.isDescriptionVisible.value
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    tooltip: isVi
                                        ? 'Thêm mô tả'
                                        : 'Add description',
                                    onPressed: controller.toggleDescription,
                                  ),
                                ),
                                // Schedule Toggle
                                Obx(
                                  () => IconButton(
                                    icon: Icon(
                                      Icons.calendar_today_outlined,
                                      color: controller.isScheduleVisible.value
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    tooltip: isVi ? 'Lên lịch' : 'Schedule',
                                    onPressed: controller.toggleSchedule,
                                  ),
                                ),
                                // Star Toggle
                                Obx(
                                  () => IconButton(
                                    icon: Icon(
                                      controller.isStarred.value
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: controller.isStarred.value
                                          ? AppColors.star
                                          : Colors.grey,
                                    ),
                                    tooltip: isVi
                                        ? 'Đánh dấu yêu thích'
                                        : 'Mark as favorite',
                                    onPressed: () =>
                                        controller.isStarred.toggle(),
                                  ),
                                ),
                                const Spacer(),
                                // Save Button
                                Obx(
                                  () => IconButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.saveTask,
                                    icon: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.save,
                                            color: AppColors.primary,
                                          ),
                                    tooltip: isVi ? 'Lưu' : 'Save',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 300),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => controller.isCompleted.value
                ? Container(
                    color: Colors.black.withOpacity(0.6),
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          const BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            isVi ? 'Đã hoàn thành' : 'Completed',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isVi
                                ? 'Công việc này đã được hoàn thành. Đánh dấu chưa hoàn thành để tiếp tục chỉnh sửa.'
                                : 'This task is completed. Mark as incomplete to edit.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white24
                                            : Colors.black12,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    isVi ? 'Hủy' : 'Cancel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: controller.markAsIncomplete,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isVi
                                        ? 'Đánh dấu chưa hoàn thành'
                                        : 'Mark as Incomplete',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCalendarToggle(BuildContext context, bool isVi) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.isLunarCalendar.value = false,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !controller.isLunarCalendar.value
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isVi ? 'Dương lịch' : 'Solar',
                      style: TextStyle(
                        color: !controller.isLunarCalendar.value
                            ? Colors.white
                            : null,
                        fontWeight: !controller.isLunarCalendar.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.isLunarCalendar.value = true,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isLunarCalendar.value
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isVi ? 'Âm lịch' : 'Lunar',
                      style: TextStyle(
                        color: controller.isLunarCalendar.value
                            ? Colors.white
                            : null,
                        fontWeight: controller.isLunarCalendar.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, bool isVi) {
    return Obx(() {
      // Logic for display strings needs to handle potentially null selectedDate
      // But in AddTaskController, if isScheduleVisible is true, selectedDate usually has a value (defaulted to Now).
      // Let's safe check just in case.
      final date = controller.selectedDate.value;
      if (date == null)
        return const SizedBox(); // Should not happen given controller logic

      return InkWell(
        onTap: () => controller.selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.isLunarCalendar.value
                          ? '${isVi ? 'Âm lịch' : 'Lunar'}: ${controller.lunarDateDisplay.value}'
                          : '${isVi ? 'Dương lịch' : 'Solar'}: ${controller.solarDateDisplay.value}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.isLunarCalendar.value
                          ? '${isVi ? 'Dương lịch' : 'Solar'}: ${controller.solarDateDisplay.value}'
                          : '${isVi ? 'Âm lịch' : 'Lunar'}: ${controller.lunarDateDisplay.value}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTimeSelector(BuildContext context, bool isVi) {
    return Obx(
      () => InkWell(
        onTap: () => controller.selectTime(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.selectedTime.value != null
                      ? '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                      : (isVi
                            ? 'Chọn giờ (Tùy chọn)'
                            : 'Select time (Optional)'),
                  style: TextStyle(
                    color: controller.selectedTime.value != null
                        ? null
                        : (Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                ),
              ),
              if (controller.selectedTime.value != null)
                GestureDetector(
                  onTap: () => controller.selectedTime.value = null,
                  child: const Icon(Icons.close, size: 20),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatSelector(BuildContext context, bool isVi) {
    final repeatOptions = [
      (RepeatType.none, isVi ? 'Không lặp' : 'No repeat'),
      (RepeatType.daily, isVi ? 'Ngày' : 'Days'),
      (RepeatType.weekly, isVi ? 'Tuần' : 'Weeks'),
      (RepeatType.monthly, isVi ? 'Tháng' : 'Months'),
      (RepeatType.yearly, isVi ? 'Năm' : 'Years'),
    ];

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Interval input
              if (controller.repeatType.value != RepeatType.none) ...[
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: controller.repeatIntervalController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Repeat type dropdown
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<RepeatType>(
                    value: controller.repeatType.value,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.chevron_right),
                    items: repeatOptions.map((option) {
                      return DropdownMenuItem<RepeatType>(
                        value: option.$1,
                        child: Row(
                          children: [
                            const Icon(Icons.repeat, size: 20),
                            const SizedBox(width: 12),
                            Text(option.$2),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.repeatType.value = value;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          // Weekly day selector
          if (controller.repeatType.value == RepeatType.weekly) ...[
            const SizedBox(height: 16),
            _buildWeekDaySelector(context, isVi),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector(BuildContext context, bool isVi) {
    // 1=Mon, 7=Sun
    final days = List.generate(7, (index) => index + 1);
    final labels = isVi
        ? ['2', '3', '4', '5', '6', '7', 'CN']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final day = days[index];
        final label = labels[index];
        final isSelected = controller.selectedWeekDays.contains(day);

        return GestureDetector(
          onTap: () => controller.toggleWeekDay(day),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.black26),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
