// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:loot_app/app/screens/auth/register_screen.dart';
import 'package:loot_app/app/screens/home/home_screen.dart';
import 'package:loot_app/app/bindings/home_binding.dart';
import 'package:loot_app/app/screens/auth/login_screen.dart'; // Crie este arquivo
import 'package:loot_app/app/bindings/auth_binding.dart';   // Crie este arquivo

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
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
    // Adicione aqui a rota para a tela principal após o login, ex: AppRoutes.DEALS_LIST
    // GetPage(
    //   name: AppRoutes.DEALS_LIST,
    //   page: () => const DealsListScreen(), // Crie esta tela
    //   binding: DealsBinding(),           // Crie este binding
    // ),
  ];
}