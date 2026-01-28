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
        title: Obx(
          () => Text(
            controller.isEditing
                ? (settings.locale.value == 'vi'
                      ? 'Sửa công việc'
                      : 'Edit task')
                : (settings.locale.value == 'vi'
                      ? 'Thêm công việc'
                      : 'Add task'),
          ),
        ),
        actions: [
          if (controller.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: controller.deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            _buildLabel(isVi ? 'Tiêu đề *' : 'Title *'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: isVi ? 'Nhập tiêu đề công việc' : 'Enter task title',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Description field
            _buildLabel(isVi ? 'Mô tả' : 'Description'),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                hintText: isVi
                    ? 'Nhập mô tả (tùy chọn)'
                    : 'Enter description (optional)',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Calendar type toggle
            _buildLabel(isVi ? 'Loại lịch' : 'Calendar type'),
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

            // Star toggle
            _buildStarToggle(isVi),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isVi ? 'Lưu' : 'Save',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
    return Obx(
      () => InkWell(
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
      ),
    );
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
                      : (isVi ? 'Chọn giờ' : 'Select time'),
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
      () => Row(
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
    );
  }

  Widget _buildStarToggle(bool isVi) {
    return Obx(
      () => InkWell(
        onTap: () => controller.isStarred.value = !controller.isStarred.value,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                controller.isStarred.value ? Icons.star : Icons.star_border,
                color: controller.isStarred.value ? AppColors.star : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(isVi ? 'Đánh dấu yêu thích' : 'Mark as favorite'),
              ),
              Switch(
                value: controller.isStarred.value,
                onChanged: (value) => controller.isStarred.value = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
