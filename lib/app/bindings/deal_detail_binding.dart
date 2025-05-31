import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';

class DealDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DealDetailController>(() => DealDetailController());
  }
}