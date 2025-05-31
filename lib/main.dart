import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Importe GetStorage
import 'package:loot_app/app/routes/app_pages.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
import 'package:loot_app/app/services/theme_service.dart'; // Importe ThemeService
import 'package:loot_app/app/services/user_preferences_service.dart';
import 'package:loot_app/app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices(); // Garante que os serviços sejam inicializados antes de runApp
  runApp(const MyApp());
}

Future<void> initializeServices() async {
  print("Inicializando GetStorage...");
  await GetStorage.init();
  print("GetStorage inicializado.");

  print("Inicializando AuthService...");
  await Get.putAsync<AuthService>(() => AuthService().init());
  print("AuthService inicializado e pronto.");

  print("Inicializando ThemeService...");
  final themeService = Get.put(ThemeService());
  themeService.initTheme();
  print("ThemeService inicializado e tema aplicado.");

  print("Inicializando UserPreferencesService..."); // Log antes
  Get.put(
    UserPreferencesService(),
  ); // Esta linha dispara o onInit() do UserPreferencesService
  print("UserPreferencesService inicializado."); // Log depois

  // ... (seu Get.put para ApiBaseUrl)
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loot',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
