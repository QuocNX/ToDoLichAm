import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:todo_lich_am/core/theme/app_theme.dart';
import 'package:todo_lich_am/features/settings/data/services/settings_service.dart';
import 'package:todo_lich_am/routes/app_pages.dart';
import 'package:todo_lich_am/routes/app_routes.dart';

/// Root widget of the application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Nhắc Việc',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode.value,

        // Localization
        locale: Locale(settings.locale.value),
        fallbackLocale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // Navigation
        initialRoute: AppRoutes.home,
        getPages: AppPages.pages,
      ),
    );
  }
}
