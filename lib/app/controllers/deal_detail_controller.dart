import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir o link da promoção

class DealDetailController extends GetxController {
  final Rxn<DealModel> deal = Rxn<DealModel>();

  // URL de redirecionamento da CheapShark
  String _getDealRedirectUrl(String? dealID) {
    if (dealID == null || dealID.isEmpty) return "https://www.cheapshark.com";
    return 'https://www.cheapshark.com/redirect?dealID=$dealID';
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is DealModel) {
      deal.value = Get.arguments as DealModel;
    } else {
      print(
        "ERRO: DealModel não foi passado como argumento para DealDetailScreen.",
      );
      Get.snackbar(
        "Erro",
        "Não foi possível carregar os detalhes da promoção.",
      );
      // Considerar Get.back() se o deal for essencial e não puder ser carregado
    }
  }

  Future<void> launchDealUrl() async {
    if (deal.value != null && deal.value!.dealID.isNotEmpty) {
      final Uri url = Uri.parse(_getDealRedirectUrl(deal.value!.dealID));
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        Get.snackbar("Erro", "Não foi possível abrir o link da promoção.");
      }
    } else {
      Get.snackbar("Indisponível", "Link da promoção não encontrado.");
    }
  }
}
