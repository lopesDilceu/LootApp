// lib/app/bindings/deals_binding.dart
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';

class DealsBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true pode ser útil para providers se você quer que persistam
    // mas para este caso, lazyPut simples deve ser suficiente.
    Get.lazyPut<DealsApiProvider>(() => DealsApiProvider());
    Get.lazyPut<DealsController>(() => DealsController());
  }
}