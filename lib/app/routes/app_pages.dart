// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:loot_app/app/bindings/main_navigation_binding.dart';
// import 'package:loot_app/app/bindings/deals_binding.dart';
import 'package:loot_app/app/bindings/splash_binding.dart';
// import 'package:loot_app/app/screens/deals/deals_list_screen.dart';
// import 'package:loot_app/app/screens/home/home_screen.dart';
// import 'package:loot_app/app/bindings/home_binding.dart';
import 'package:loot_app/app/screens/main_navigation/main_navigation_screen.dart';
import 'package:loot_app/app/screens/splash/splash_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(
      name: AppRoutes.MAIN_NAVIGATION,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(), // Este binding agora registra AuthController também
    ),
    // Rotas LOGIN, REGISTER, PROFILE, SETTINGS foram removidas como GetPages independentes
  ];
}