// lib/app/bindings/auth_binding.dart
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/auth/login_controller.dart';
import 'package:loot_app/app/controllers/auth/register_controller.dart';
import 'package:loot_app/app/data/providers/auth_api_provider.dart';
// Importe o RegisterController e AuthApiProvider quando for usá-los
// import 'package:loot_app/app/controllers/register_controller.dart';
// import 'package:loot_app/app/data/providers/auth_api_provider.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiProvider>(() => AuthApiProvider(), fenix: true);
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<RegisterController>(() => RegisterController());
  }
}
