// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:loot_app/app/bindings/deal_detail_binding.dart';
import 'package:loot_app/app/bindings/main_navigation_binding.dart';
// import 'package:loot_app/app/bindings/deals_binding.dart';
import 'package:loot_app/app/bindings/splash_binding.dart';
import 'package:loot_app/app/screens/auth/register_screen.dart';
import 'package:loot_app/app/screens/deals/deal_detail_screen.dart';
// import 'package:loot_app/app/screens/deals/deals_list_screen.dart';
// import 'package:loot_app/app/screens/home/home_screen.dart';
// import 'package:loot_app/app/bindings/home_binding.dart';
import 'package:loot_app/app/screens/auth/login_screen.dart'; // Crie este arquivo
import 'package:loot_app/app/bindings/auth_binding.dart';   // Crie este arquivo
import 'package:loot_app/app/screens/main_navigation/main_navigation_screen.dart';
import 'package:loot_app/app/screens/splash/splash_screen.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    // GetPage(
    //   name: AppRoutes.HOME,
    //   page: () => const HomeScreen(),
    //   binding: HomeBinding(),
    // ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(), // Crie um placeholder para esta tela
      binding: AuthBinding(),      // Crie um placeholder para este binding
    ),
    GetPage(
      name: AppRoutes.REGISTER, // Rota de Cadastro
      page: () => const RegisterScreen(),
      binding: AuthBinding(), // Pode usar o mesmo AuthBinding
    ),
    // GetPage(
    //   name: AppRoutes.DEALS_LIST,
    //   page: () => const DealsListScreen(), // Crie a UI para esta tela
    //   binding: DealsBinding(),
    // ),
    GetPage(
      name: AppRoutes.DEAL_DETAIL,
      page: () => const DealDetailScreen(),
      binding: DealDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN_NAVIGATION,
      page: () => const MainNavigationScreen(),
      binding: MainNavigationBinding(),
    ),
  ];
}