import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart'; // Para ApiConstants.imageProxyUrlPrefix
// UserPreferencesService e CurrencyService serão acessados pela UI (DealDetailScreenContent)
// import 'package:loot_app/app/services/user_preferences_service.dart';
// import 'package:loot_app/app/services/currency_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DealDetailController extends GetxController {
  final Rxn<DealModel> deal = Rxn<DealModel>(); // O deal da CheapShark

  // O listener para mudança de país não é mais necessário aqui se a UI
  // (DealDetailScreenContent) já observa o UserPreferencesService e o CurrencyService
  // para reconstruir e chamar CurrencyService.getFormattedPrice.
  // Worker? _countryChangeListener;

  @override
  void onInit() {
    super.onInit();
    print("[DealDetailController] onInit. Aguardando chamada de loadDealDetails.");
    // A lógica de buscar Get.arguments foi removida daqui.
  }

  @override
  void onClose() {
    print("[DealDetailController] onClose. Limpando deal.");
    clearDealDetails(); // Garante limpeza ao fechar
    super.onClose();
  }

  // Método chamado pelo MainNavigationController para carregar/atualizar o deal
  void loadDealDetails(DealModel newDeal) {
    print("[DealDetailController] loadDealDetails chamado com: ${newDeal.title}");
    deal.value = newDeal; // Define o deal principal que a UI vai observar

    // Não há mais busca de preço regional da GG.deals aqui.
    // A DealDetailScreenContent usará o CurrencyService para formatar os preços
    // do deal.value (que são em USD) com base na preferência do usuário.
    // A reatividade à mudança de moeda acontecerá na UI (DealDetailScreenContent)
    // que observa o UserPreferencesService e o CurrencyService.
    print("[DealDetailController] Deal carregado: ${deal.value?.title}");
  }
  
  // Método para limpar o deal atual (chamado por MainNavigationController ao fechar a página)
  void clearDealDetails() {
    print("[DealDetailController] Limpando detalhes do deal.");
    deal.value = null;
    // _countryChangeListener?.dispose(); // Removido
  }

  // Getter para a URL da imagem (já inclui o proxy)
  String get displayImageUrl {
    if (deal.value == null || deal.value!.thumb.isEmpty) { // Verifica se deal.value e thumb são válidos
        print("[DealDetailController] displayImageUrl: deal ou thumb é nulo/vazio.");
        return ''; // Retorna string vazia se não houver deal ou thumb
    }

    final currentDeal = deal.value!;
    String imageUrlToUse = currentDeal.thumb; // Começa com a thumbnail

    // Tenta usar uma imagem maior da Steam se steamAppID estiver disponível
    if (currentDeal.steamAppID != null && currentDeal.steamAppID!.isNotEmpty) {
      imageUrlToUse = 'https://steamcdn-a.akamaihd.net/steam/apps/${currentDeal.steamAppID}/header.jpg';
      print("[DealDetailController] displayImageUrl: Usando URL da Steam (header.jpg): $imageUrlToUse");
    } else {
      print("[DealDetailController] displayImageUrl: Sem steamAppID, usando thumbnail: $imageUrlToUse");
    }
    
    if (imageUrlToUse.isEmpty) { // Segunda checagem para imageUrlToUse
        print("[DealDetailController] displayImageUrl: imageUrlToUse final está vazia.");
        return '';
    }

    String encodedImageUrl = Uri.encodeComponent(imageUrlToUse);
    final proxiedUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl"; 
    print("[DealDetailController] displayImageUrl: URL final do proxy: $proxiedUrl");
    return proxiedUrl;
  }

  // Método para abrir o link da promoção
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