import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:todo_lich_am/common/widgets/lunar_date_picker.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/utils/lunar_calendar_utils.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/domain/entities/task_entity.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';

/// Controller for add/edit task page.
class AddTaskController extends GetxController {
  final TaskRepository _repository;

  AddTaskController(this._repository);

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final repeatIntervalController = TextEditingController(text: '1');

  // Observable state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxBool isLunarCalendar = false.obs;
  final Rx<RepeatType> repeatType = RepeatType.none.obs;
  final RxInt repeatInterval = 1.obs;
  final RxBool isStarred = false.obs;
  final RxBool isLoading = false.obs;

  // For editing an existing task
  TaskEntity? editingTask;
  bool get isEditing => editingTask != null;

  // Lunar date display
  final RxString lunarDateDisplay = ''.obs;
  final RxString solarDateDisplay = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if we're editing an existing task
    if (Get.arguments is TaskEntity) {
      editingTask = Get.arguments as TaskEntity;
      _loadTaskData(editingTask!);
    }

    _updateDateDisplays();

    // Listen to date and calendar type changes
    ever(selectedDate, (_) => _updateDateDisplays());
    ever(isLunarCalendar, (_) => _updateDateDisplays());

    repeatIntervalController.addListener(() {
      final val = int.tryParse(repeatIntervalController.text);
      if (val != null) {
        repeatInterval.value = val;
      }
    });
  }

  void _loadTaskData(TaskEntity task) {
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    selectedDate.value = task.dueDate;
    if (task.time != null) {
      selectedTime.value = TimeOfDay(
        hour: task.time!.hour,
        minute: task.time!.minute,
      );
    }
    isLunarCalendar.value = task.isLunarCalendar;
    repeatType.value = task.repeatType;
    repeatInterval.value = task.repeatInterval;
    repeatIntervalController.text = task.repeatInterval.toString();
    isStarred.value = task.isStarred;
  }

  void _updateDateDisplays() {
    final lunar = LunarCalendarUtils.solarToLunar(selectedDate.value);

    lunarDateDisplay.value =
        '${lunar.getDay()}/${lunar.getMonth()}/${lunar.getYear()}';
    solarDateDisplay.value =
        '${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}';
  }

  /// Selects a date using the appropriate picker.
  Future<void> selectDate(BuildContext context) async {
    final settings = Get.find<SettingsService>();

    if (isLunarCalendar.value) {
      await showModalBottomSheet(
        context: context,
        builder: (context) => LunarDatePicker(
          initialDate: selectedDate.value,
          locale: settings.locale.value,
          onDateChanged: (date) {
            selectedDate.value = date;
          },
        ),
      );
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        locale: Locale(settings.locale.value),
      );
      if (picked != null) {
        selectedDate.value = picked;
      }
    }
  }

  /// Selects time.
  Future<void> selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  /// Saves the task.
  Future<void> saveTask() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập tiêu đề công việc',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Convert time to DateTime if selected
      DateTime? taskTime;
      if (selectedTime.value != null) {
        taskTime = DateTime(
          selectedDate.value.year,
          selectedDate.value.month,
          selectedDate.value.day,
          selectedTime.value!.hour,
          selectedTime.value!.minute,
        );
      }

      // Get lunar date info if using lunar calendar
      int? lunarDay, lunarMonth, lunarYear;
      if (isLunarCalendar.value) {
        final lunar = LunarCalendarUtils.solarToLunar(selectedDate.value);
        lunarDay = lunar.getDay();
        lunarMonth = lunar.getMonth();
        lunarYear = lunar.getYear();
      }

      final task = TaskEntity(
        id: editingTask?.id ?? const Uuid().v4(),
        title: titleController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        dueDate: selectedDate.value,
        time: taskTime,
        isLunarCalendar: isLunarCalendar.value,
        repeatType: repeatType.value,
        repeatInterval: int.tryParse(repeatIntervalController.text) ?? 1,
        isCompleted: editingTask?.isCompleted ?? false,
        isStarred: isStarred.value,
        category: editingTask?.category ?? 'default',
        createdAt: editingTask?.createdAt ?? DateTime.now(),
        lunarDay: lunarDay,
        lunarMonth: lunarMonth,
        lunarYear: lunarYear,
      );

      if (isEditing) {
        await _repository.updateTask(task);
      } else {
        await _repository.addTask(task);
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể lưu công việc',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Deletes the current task (only for editing).
  Future<void> deleteTask() async {
    if (!isEditing) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa?'),
        content: const Text('Bạn có chắc muốn xóa công việc này?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteTask(editingTask!.id);
      Get.back(result: true);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    repeatIntervalController.dispose();
    super.onClose();
  }
}
