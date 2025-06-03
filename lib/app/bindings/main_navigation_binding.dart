import 'package:get/get.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/controllers/monitoring_controller.dart';
import 'package:loot_app/app/controllers/profile_controller.dart';
import 'package:loot_app/app/controllers/settings_controller.dart'; // Importe
import 'package:loot_app/app/data/providers/deals_api_provider.dart';

class MainNavigationBinding extends Bindings {
  @override
  void dependencies() {
    print("[MainNavigationBinding] Registrando dependências...");

    Get.lazyPut<DealsApiProvider>(() => DealsApiProvider(), fenix: true);

    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<DealsController>(() => DealsController(), fenix: true);
    Get.lazyPut<MonitoringController>(() => MonitoringController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true); // Registra SettingsController
    
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    print("[MainNavigationBinding] Dependências registradas.");
  }
}