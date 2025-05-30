import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class SplashController extends GetxController {
  @override
  void onReady() { // onReady é chamado após a UI ser renderizada
    super.onReady();
    _checkAuthStatusAndNavigate();
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    // Pequeno delay para mostrar a splash screen (opcional)
    await Future.delayed(const Duration(seconds: 2));

    // AuthService.to já terá executado tryAutoLogin() a partir do seu onInit
    if (AuthService.to.isLoggedIn) {
      Get.offAllNamed(AppRoutes.DEALS_LIST); // Vai para a home logada
    } else {
      Get.offAllNamed(AppRoutes.HOME); // Vai para a home não logada (que tem o botão de login)
    }
  }
}