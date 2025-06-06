import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Importe GetStorage
import 'package:loot_app/app/data/providers/ggd_api_provider.dart';
import 'package:loot_app/app/routes/app_pages.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
import 'package:loot_app/app/services/currency_service.dart';
import 'package:loot_app/app/services/theme_service.dart'; // Importe ThemeService
import 'package:loot_app/app/services/user_preferences_service.dart';
import 'package:loot_app/app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices(); // Garante que os serviços sejam inicializados antes de runApp
  runApp(const MyApp());
}

Future<void> initializeServices() async {
  await GetStorage.init();

  await Get.putAsync<AuthService>(() => AuthService().init());

  final themeService = Get.put(ThemeService());
  themeService.initTheme();

  Get.put(GGDotDealsApiProvider());
  Get.put(UserPreferencesService(),); // Esta linha dispara o onInit() do UserPreferencesService

  // await Get.putAsync<CurrencyService>(() => CurrencyService().initService()); // Chama o initService

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LooT',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
