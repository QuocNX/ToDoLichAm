import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_lich_am/app.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/features/todo/data/models/task_model.dart';
import 'package:todo_lich_am/features/settings/data/services/first_run_service.dart';
import 'package:todo_lich_am/core/services/notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(TaskModelAdapter());

  // Initialize global services
  await Get.putAsync<SettingsService>(() async => SettingsService().init());
  await Get.putAsync<NotificationService>(
    () async => NotificationService().init(),
  );
  await Get.putAsync<FirstRunService>(() async => FirstRunService().init());

  await SentryFlutter.init((options) {
    options.dsn =
        'https://examplePublicKey@o0.ingest.sentry.io/0'; // TODO: Update DSN
    options.tracesSampleRate =
        1.0; // Capture 100% of transactions for performance monitoring.
  }, appRunner: () => runApp(const App()));
}
