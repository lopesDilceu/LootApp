import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';

class HomeController extends GetxController{
  void navigateToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }


}