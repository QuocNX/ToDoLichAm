import 'package:get/get.dart';
import 'package:todo_lich_am/features/todo/data/datasources/local/task_local_datasource.dart';
import 'package:todo_lich_am/features/todo/data/repositories/task_repository_impl.dart';
import 'package:todo_lich_am/features/todo/domain/repositories/task_repository.dart';
import 'package:todo_lich_am/features/todo/presentation/controllers/home_controller.dart';

/// Binding for HomePage dependencies.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<TaskLocalDataSource>(() => TaskLocalDataSource());

    // Repositories
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(Get.find<TaskLocalDataSource>()),
    );

    // Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<TaskRepository>()),
    );
  }
}
