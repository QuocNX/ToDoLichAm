import 'package:get/get.dart';
import 'package:todo_lich_am/features/todo/data/datasources/local/task_local_datasource.dart';
import 'package:todo_lich_am/features/todo/data/repositories/task_repository_impl.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/add_task_controller.dart';

/// Binding for AddTaskPage dependencies.
class AddTaskBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure repository is available
    if (!Get.isRegistered<TaskRepository>()) {
      Get.lazyPut<TaskLocalDataSource>(() => TaskLocalDataSource());
      Get.lazyPut<TaskRepository>(
        () => TaskRepositoryImpl(Get.find<TaskLocalDataSource>()),
      );
    }

    // Controller
    Get.lazyPut<AddTaskController>(
      () => AddTaskController(Get.find<TaskRepository>()),
    );
  }
}
