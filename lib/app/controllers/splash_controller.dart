import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class SplashController extends GetxController {
  SplashController() { // Construtor
    print("[SplashController] CONSTRUTOR - INÍCIO"); // Novo log
    // ... qualquer outra lógica de construtor se houver ...
    print("[SplashController] CONSTRUTOR - FIM");   // Novo log
  }

  @override
  void onInit() {
    print("[SplashController] ONINIT - INÍCIO"); // Novo log
    super.onInit();
    print("[SplashController] ONINIT - FIM");    // Novo log
  }

  @override
  void onReady() {
    print("[SplashController] ONREADY - INÍCIO"); // Novo log
    super.onReady();
    print("[SplashController] ONREADY - Verificando status de autenticação...");
    _checkAuthStatusAndNavigate();
  }

  Future<void> _checkAuthStatusAndNavigate() async {
    try {
      print("[SplashController] _checkAuthStatusAndNavigate - INÍCIO");
      await Future.delayed(const Duration(seconds: 1)); 

      final authService = AuthService.to;
      print("[SplashController] AuthService instance obtained. Initialized: ${authService.isServiceInitialized}, LoggedIn: ${authService.isAuthenticated}");

      if (authService.isAuthenticated.value) {
        print("[SplashController] Usuário LOGADO. Navegando para ${AppRoutes.DEALS_LIST}...");
        Get.offAllNamed(AppRoutes.DEALS_LIST);
      } else {
        print("[SplashController] Usuário NÃO LOGADO. Navegando para ${AppRoutes.HOME}...");
        Get.offAllNamed(AppRoutes.HOME);
      }
      print("[SplashController] Navegação via Get.offAllNamed FOI CHAMADA.");

    } catch (e, stackTrace) {
      print("[SplashController] ERRO CRÍTICO em _checkAuthStatusAndNavigate: $e");
      print("[SplashController] StackTrace do erro: $stackTrace");
      Get.offAllNamed(AppRoutes.LOGIN); // Fallback em caso de erro crítico
    }
  }
}