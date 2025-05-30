import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart'; // Importe

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print("[HomeBinding] dependencies() chamado");
    // Fornece o DealsApiProvider para o HomeController
    Get.lazyPut<DealsApiProvider>(() => DealsApiProvider()); 
    Get.lazyPut<HomeController>(() => HomeController());
  }
}