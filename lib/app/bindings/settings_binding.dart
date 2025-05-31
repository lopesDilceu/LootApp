import 'package:get/get.dart';
import 'package:loot_app/app/controllers/settings_controller.dart';
// ThemeService e UserPreferencesService já devem estar registrados globalmente (em main.dart)

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}