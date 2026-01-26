import 'package:get/get.dart';
import 'package:todo_lich_am/routes/app_routes.dart';
import 'package:todo_lich_am/features/todo/presentation/bindings/home_binding.dart';
import 'package:todo_lich_am/features/todo/presentation/pages/home_page.dart';
import 'package:todo_lich_am/features/todo/presentation/bindings/add_task_binding.dart';
import 'package:todo_lich_am/features/todo/presentation/pages/add_task_page.dart';
import 'package:todo_lich_am/features/todo/presentation/pages/task_detail_page.dart';
import 'package:todo_lich_am/features/settings/presentation/pages/settings_page.dart';
import 'package:todo_lich_am/features/settings/presentation/bindings/settings_binding.dart';
import 'package:todo_lich_am/features/about/presentation/pages/about_page.dart';

/// GetX pages configuration.
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.addTask,
      page: () => const AddTaskPage(),
      binding: AddTaskBinding(),
    ),
    GetPage(
      name: AppRoutes.editTask,
      page: () => const AddTaskPage(),
      binding: AddTaskBinding(),
    ),
    GetPage(name: AppRoutes.taskDetail, page: () => const TaskDetailPage()),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
  ];
}
