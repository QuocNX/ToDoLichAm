import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';
import 'package:todo_lich_am/features/settings/data/services/backup_service.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/routes/app_routes.dart';
import 'package:todo_lich_am/common/widgets/delete_tasks_dialog.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/home_controller.dart';
import 'package:todo_lich_am/core/services/notification_service.dart';

/// Settings page for configuring app preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(settings.locale.value == 'vi' ? 'Cài đặt' : 'Settings'),
        ),
      ),
      body: Obx(() {
        final isVi = settings.locale.value == 'vi';

        return ListView(
          children: [
            // Calendar mode section
            _buildSectionHeader(
              context,
              isVi ? 'Chế độ lịch' : 'Calendar mode',
            ),
            _buildCalendarModeSelector(context, settings, isVi),

            const Divider(),

            // Theme section
            _buildSectionHeader(context, isVi ? 'Giao diện' : 'Theme'),
            _buildThemeSelector(context, settings, isVi),

            const Divider(),

            // Language section
            _buildSectionHeader(context, isVi ? 'Ngôn ngữ' : 'Language'),
            _buildLanguageSelector(context, settings),

            const Divider(),

            // Backup & Restore
            _buildSectionHeader(
              context,
              isVi ? 'Sao lưu & Khôi phục' : 'Backup & Restore',
            ),
            _buildBackupRestoreSection(context, isVi),

            const Divider(),

            // About section
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(isVi ? 'Thông tin ứng dụng' : 'About app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.about),
            ),

            const Divider(),

            // Clear data section
            _buildSectionHeader(context, isVi ? 'Dữ liệu' : 'Data'),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: Text(isVi ? 'Xóa toàn bộ dữ liệu' : 'Clear all data'),
              onTap: () => _showDeleteDialog(context),
            ),

            const Divider(),

            // Notification debugging section
            _buildSectionHeader(
              context,
              isVi ? 'Kiểm tra thông báo' : 'Test Notifications',
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
              ),
              title: Text(
                isVi ? 'Gửi thông báo test' : 'Send test notification',
              ),
              subtitle: Text(
                isVi
                    ? 'Bấm để kiểm tra thông báo có hoạt động không'
                    : 'Tap to test if notifications work',
              ),
              onTap: () async {
                final notificationService = Get.find<NotificationService>();
                await notificationService.showTestNotification();
                Get.snackbar(
                  isVi ? 'Đã gửi' : 'Sent',
                  isVi
                      ? 'Kiểm tra thanh thông báo của bạn'
                      : 'Check your notification bar',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.purple),
              title: Text(isVi ? 'Test hẹn giờ (10s)' : 'Test scheduled (10s)'),
              subtitle: Text(
                isVi
                    ? 'Kiểm tra chức năng hẹn giờ (chờ 10s)'
                    : 'Test scheduling (wait 10s)',
              ),
              onTap: () async {
                final notificationService = Get.find<NotificationService>();
                try {
                  await notificationService.scheduleTestNotification();
                  Get.snackbar(
                    isVi ? 'Đã hẹn' : 'Scheduled',
                    isVi
                        ? 'Chờ 10s xem có thông báo không'
                        : 'Wait 10s for notification',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Lỗi / Error'),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.blue),
              title: Text(
                isVi ? 'Xem thông báo đã hẹn' : 'View pending notifications',
              ),
              onTap: () async {
                final notificationService = Get.find<NotificationService>();
                final pending = await notificationService
                    .getPendingNotifications();
                Get.dialog(
                  AlertDialog(
                    title: Text(
                      isVi
                          ? 'Thông báo đã hẹn (${pending.length})'
                          : 'Pending notifications (${pending.length})',
                    ),
                    content: SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: pending.isEmpty
                          ? Center(
                              child: Text(
                                isVi
                                    ? 'Không có thông báo nào'
                                    : 'No pending notifications',
                              ),
                            )
                          : ListView.builder(
                              itemCount: pending.length,
                              itemBuilder: (context, index) {
                                final n = pending[index];
                                return ListTile(
                                  title: Text(n.title ?? 'No title'),
                                  subtitle: Text(
                                    'ID: ${n.id}\n${n.body ?? ''}',
                                  ),
                                  isThreeLine: true,
                                );
                              },
                            ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(isVi ? 'Đóng' : 'Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final result = await Get.dialog<Map<String, bool>>(
      const DeleteTasksDialog(),
    );

    if (result != null) {
      final homeController = Get.find<HomeController>();
      if (result['deleteAll'] == true) {
        await homeController.deleteAllTasks();
      } else if (result['deleteCompleted'] == true) {
        await homeController.deleteCompletedTasks();
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildCalendarModeSelector(
    BuildContext context,
    SettingsService settings,
    bool isVi,
  ) {
    final options = [
      (AppStrings.calendarModeLunar, isVi ? 'Chỉ âm lịch' : 'Lunar only'),
      (AppStrings.calendarModeSolar, isVi ? 'Chỉ dương lịch' : 'Solar only'),
      (AppStrings.calendarModeBoth, isVi ? 'Cả hai' : 'Both'),
    ];

    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          value: option.$1,
          groupValue: settings.calendarMode.value,
          title: Text(option.$2),
          onChanged: (value) {
            if (value != null) {
              settings.setCalendarMode(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsService settings,
    bool isVi,
  ) {
    final options = [
      (ThemeMode.light, isVi ? 'Chế độ sáng' : 'Light mode', Icons.light_mode),
      (ThemeMode.dark, isVi ? 'Chế độ tối' : 'Dark mode', Icons.dark_mode),
      (
        ThemeMode.system,
        isVi ? 'Theo hệ thống' : 'System',
        Icons.settings_suggest,
      ),
    ];

    return Column(
      children: options.map((option) {
        return RadioListTile<ThemeMode>(
          value: option.$1,
          groupValue: settings.themeMode.value,
          title: Row(
            children: [
              Icon(option.$3, size: 20),
              const SizedBox(width: 12),
              Text(option.$2),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsService settings,
  ) {
    final options = [('vi', 'Tiếng Việt', '🇻🇳'), ('en', 'English', '🇺🇸')];

    return Column(
      children: options.map((option) {
        return RadioListTile<String>(
          value: option.$1,
          groupValue: settings.locale.value,
          title: Row(
            children: [
              Text(option.$3, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(option.$2),
            ],
          ),
          onChanged: (value) {
            if (value != null) {
              settings.setLocale(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildBackupRestoreSection(BuildContext context, bool isVi) {
    final backupService = Get.put(BackupService());

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.download),
          title: Text(isVi ? 'Sao lưu dữ liệu' : 'Backup data'),
          subtitle: Text(isVi ? 'Xuất dữ liệu ra file' : 'Export data to file'),
          onTap: () => backupService.exportData(),
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: Text(isVi ? 'Khôi phục dữ liệu' : 'Restore data'),
          subtitle: Text(
            isVi ? 'Nhập dữ liệu từ file' : 'Import data from file',
          ),
          onTap: () => backupService.importData(),
        ),
      ],
    );
  }
}
