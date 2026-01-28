import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/features/settings/data/services/first_run_service.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';

/// Dialog widget for first run holiday selection.
class FirstRunDialog extends StatefulWidget {
  final TaskRepository taskRepository;

  const FirstRunDialog({super.key, required this.taskRepository});

  @override
  State<FirstRunDialog> createState() => _FirstRunDialogState();
}

class _FirstRunDialogState extends State<FirstRunDialog> {
  bool _addSolarHolidays = true;
  bool _addLunarHolidays = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final isVi = settings.locale.value == 'vi';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.celebration,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isVi ? 'Chào mừng!' : 'Welcome!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isVi ? 'Thêm ngày lễ mặc định' : 'Add default holidays',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Description
            Text(
              isVi
                  ? 'Bạn có muốn thêm các ngày lễ Việt Nam vào danh sách công việc không?'
                  : 'Would you like to add Vietnamese holidays to your task list?',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Solar holidays checkbox
            _buildCheckboxTile(
              context: context,
              value: _addSolarHolidays,
              onChanged: (value) {
                setState(() {
                  _addSolarHolidays = value ?? false;
                });
              },
              icon: Icons.wb_sunny_outlined,
              iconColor: Colors.orange,
              title: isVi ? 'Ngày lễ dương lịch' : 'Solar holidays',
              subtitle: isVi
                  ? 'Tết Dương lịch, Quốc khánh, Giáng sinh...'
                  : "New Year's Day, National Day, Christmas...",
            ),

            const SizedBox(height: 12),

            // Lunar holidays checkbox
            _buildCheckboxTile(
              context: context,
              value: _addLunarHolidays,
              onChanged: (value) {
                setState(() {
                  _addLunarHolidays = value ?? false;
                });
              },
              icon: Icons.nights_stay_outlined,
              iconColor: Colors.indigo,
              title: isVi ? 'Ngày lễ âm lịch' : 'Lunar holidays',
              subtitle: isVi
                  ? 'Tết Nguyên Đán, Trung Thu, Vu Lan...'
                  : 'Lunar New Year, Mid-Autumn, Ghost Festival...',
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _skipHolidays,
                  child: Text(
                    isVi ? 'Bỏ qua' : 'Skip',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addHolidays,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(isVi ? 'Thêm' : 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: value ? AppColors.primary : Theme.of(context).dividerColor,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: value ? AppColors.primary.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addHolidays() async {
    if (!_addSolarHolidays && !_addLunarHolidays) {
      _skipHolidays();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firstRunService = Get.find<FirstRunService>();
      final settings = Get.find<SettingsService>();
      final locale = settings.locale.value;

      if (_addSolarHolidays) {
        await firstRunService.addSolarHolidays(widget.taskRepository, locale);
      }

      if (_addLunarHolidays) {
        await firstRunService.addLunarHolidays(widget.taskRepository, locale);
      }

      await firstRunService.markFirstRunComplete();

      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      debugPrint('Error adding holidays: $e');
      if (mounted) {
        Get.back(result: false);
      }
    }
  }

  void _skipHolidays() async {
    final firstRunService = Get.find<FirstRunService>();
    await firstRunService.markFirstRunComplete();
    if (mounted) {
      Get.back(result: false);
    }
  }
}
