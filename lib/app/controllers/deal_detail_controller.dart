import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir o link da promoção

class DealDetailController extends GetxController {
  final Rxn<DealModel> deal = Rxn<DealModel>();

  // Getter para a URL da imagem que deve ser exibida na tela de detalhes
  String get displayImageUrl {
    if (deal.value == null) return '';

    final currentDeal = deal.value!;
    String imageUrlToUse = currentDeal.thumb;

    if (currentDeal.steamAppID != null && currentDeal.steamAppID!.isNotEmpty) {
      imageUrlToUse = 'https://steamcdn-a.akamaihd.net/steam/apps/${currentDeal.steamAppID}/header.jpg';
      print("[DealDetailController] Usando URL da Steam (header.jpg): $imageUrlToUse");
    } else {
      print("[DealDetailController] Sem steamAppID, usando thumbnail: $imageUrlToUse");
    }
    
    if (imageUrlToUse.isEmpty) return '';

    String encodedImageUrl = Uri.encodeComponent(imageUrlToUse);
    // VVVVVV USA A CONSTANTE AQUI VVVVVV
    final proxiedUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl"; 
    print("[DealDetailController] URL final do proxy para a imagem: $proxiedUrl");
    return proxiedUrl;
  }

  @override
  void onInit() {
    super.onInit();
    print("[DealDetailController] onInit. Argumentos: ${Get.arguments}");
    if (Get.arguments is DealModel) {
      deal.value = Get.arguments as DealModel;
    } else {
      print("ERRO: DealModel não foi passado como argumento para DealDetailScreen. Tipo: ${Get.arguments?.runtimeType}");
      Get.snackbar("Erro", "Não foi possível carregar os detalhes da promoção.");
    }
  }

  // Método para abrir o link da promoção (como antes)
  String _getDealRedirectUrl(String? dealID) {
    if (dealID == null || dealID.isEmpty) return "https://www.cheapshark.com";
    return 'https://www.cheapshark.com/redirect?dealID=$dealID';
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