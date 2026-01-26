import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/constants/app_colors.dart';
import 'package:todo_lich_am/core/constants/app_strings.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';

/// About page with author info and donation details.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // TODO: Replace with actual author info
  static const String authorName = 'Nguyễn Xuân Quốc';
  static const String bankName = 'Vietcombank';
  static const String accountNumber = '1234567890';
  static const String accountHolder = 'NGUYEN XUAN QUOC';
  static const String email = 'quocnx@example.com';
  static const String facebook = 'facebook.com/quocnx';

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();
    final isVi = settings.locale.value == 'vi';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(isVi ? 'Thông tin' : 'About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App logo and info
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ToDoLichAm',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              isVi ? 'Nhắc việc theo Âm Lịch' : 'Lunar Calendar To-Do',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isVi ? 'Phiên bản' : 'Version'} ${AppStrings.appVersion}',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 32),

            // Author info
            _buildSection(
              context: context,
              title: isVi ? 'Tác giả' : 'Author',
              icon: Icons.person,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text(authorName),
                  subtitle: Text(email),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Support section
            _buildSection(
              context: context,
              title: isVi ? 'Ủng hộ tác giả' : 'Support author',
              icon: Icons.favorite,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        isVi
                            ? 'Nếu bạn thấy ứng dụng hữu ích, hãy ủng hộ tác giả nhé!'
                            : 'If you find this app useful, please support the author!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // QR placeholder
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightDivider),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code,
                            size: 100,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildBankInfoRow(
                  context,
                  isVi ? 'Ngân hàng' : 'Bank',
                  bankName,
                  copyable: false,
                ),
                _buildBankInfoRow(
                  context,
                  isVi ? 'Số tài khoản' : 'Account',
                  accountNumber,
                  copyable: true,
                  isVi: isVi,
                ),
                _buildBankInfoRow(
                  context,
                  isVi ? 'Chủ tài khoản' : 'Holder',
                  accountHolder,
                  copyable: false,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact section
            _buildSection(
              context: context,
              title: isVi ? 'Liên hệ' : 'Contact',
              icon: Icons.contact_mail,
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: const Text(email),
                  onTap: () {
                    // TODO: Open email
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.facebook),
                  title: const Text('Facebook'),
                  subtitle: const Text(facebook),
                  onTap: () {
                    // TODO: Open Facebook
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Made with love
            Text(
              isVi ? 'Được tạo với ❤️ tại Việt Nam' : 'Made with ❤️ in Vietnam',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBankInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
    bool isVi = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (copyable) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.snackbar(
                      isVi ? 'Đã sao chép' : 'Copied',
                      value,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: const Icon(
                    Icons.copy,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
