import 'package:get/get.dart';
import 'package:loot_app/app/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    print("[SplashBinding] dependencies() chamado - Tentando registrar SplashController...");
    try {
      Get.put<SplashController>(SplashController());
      print("[SplashBinding] SplashController registrado com sucesso via lazyPut.");
    } catch (e, stackTrace) {
      print("[SplashBinding] ERRO AO REGISTRAR SplashController: $e");
      print("[SplashBinding] StackTrace do erro no binding: $stackTrace");
    }
  }
}