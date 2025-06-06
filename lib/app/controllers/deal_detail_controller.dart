import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart'; // Para ApiConstants.imageProxyUrlPrefix
import 'package:loot_app/app/data/providers/rawg_api_provider.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';
// UserPreferencesService e CurrencyService serão acessados pela UI (DealDetailScreenContent)
// import 'package:loot_app/app/services/user_preferences_service.dart';
// import 'package:loot_app/app/services/currency_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DealDetailController extends GetxController {
  final Rxn<DealModel> deal = Rxn<DealModel>();
  final RawgApiProvider _rawgApiProvider = Get.find<RawgApiProvider>(); // Injete/Encontre
  final UserPreferencesService _prefsService = UserPreferencesService.to;

  // Para o carrossel de imagens da RAWG
  final RxList<String> gameImageUrls = <String>[].obs;
  final RxBool isLoadingImages = false.obs;
  late PageController imageCarouselController;
  var currentImageIndex = 0.obs; // Para o indicador de página

  Worker? _countryChangeListener;

  @override
  void onInit() {
    super.onInit();
    print("[DealDetailController] onInit.");
    imageCarouselController = PageController(viewportFraction: 0.9); // Para o carrossel
  }
  
  @override
  void onClose() {
    print("[DealDetailController] onClose. Limpando deal e controller do carrossel.");
    imageCarouselController.dispose();
    _countryChangeListener?.dispose();
    clearDealDetails();
    super.onClose();
  }

  Future<void> loadDealDetails(DealModel newDeal) async {
    print("[DealDetailController] loadDealDetails chamado com: ${newDeal.title}");
    deal.value = newDeal;
    gameImageUrls.clear(); // Limpa imagens anteriores
    currentImageIndex.value = 0; // Reseta o índice do carrossel

    _countryChangeListener?.dispose();
    _countryChangeListener = ever(_prefsService.selectedCurrency, (_) { // Ou selectedCountryCode se preferir
      print("[DealDetailController] Moeda/País mudou. A UI de preço deve se atualizar.");
      // A UI de preço já observa CurrencyService e UserPreferencesService.
      // Se precisar buscar algo específico aqui (como preços da GG.deals), faça.
    });

    if (deal.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isClosed) return;
        _fetchGameScreenshots(); // Busca imagens da RAWG
      });
    }
  }
  
  // Método para limpar o deal atual (chamado por MainNavigationController ao fechar a página)
  void clearDealDetails() {
    deal.value = null;
    gameImageUrls.clear();
    currentImageIndex.value = 0;
    _countryChangeListener?.dispose();
    _countryChangeListener = null;
  }

  Future<void> _fetchGameScreenshots() async {
    if (deal.value == null) return;
    isLoadingImages.value = true;
    // Limpa a lista antes de adicionar novas imagens para evitar duplicatas em re-chamadas
    final List<String> fetchedImages = []; 

    // 1. Tenta adicionar a header.jpg da Steam primeiro, se disponível
    if (deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
      final steamHeaderUrl = 'https://steamcdn-a.akamaihd.net/steam/apps/${deal.value!.steamAppID}/header.jpg';
      fetchedImages.add(steamHeaderUrl);
      print("[DealDetailController] Adicionada Steam header.jpg: $steamHeaderUrl");
    }

    // 2. Busca screenshots da RAWG
    int? rawgGameId;
    if (deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
      rawgGameId = await _rawgApiProvider.findRawgGameIdBySteamId(deal.value!.steamAppID!);
    }
    if (rawgGameId == null) { 
      rawgGameId = await _rawgApiProvider.findRawgGameIdByTitle(deal.value!.title);
    }
    
    if (rawgGameId != null) {
      final screenshots = await _rawgApiProvider.getGameScreenshots(rawgGameId);
      if (screenshots.isNotEmpty) {
        for (var screenshotUrl in screenshots) {
          // Adiciona apenas se não for uma duplicata da header.jpg (pouco provável, mas seguro)
          if (!fetchedImages.contains(screenshotUrl)) {
            fetchedImages.add(screenshotUrl);
          }
        }
        print("[DealDetailController] ${screenshots.length} screenshots da RAWG adicionadas.");
      }
    }
    
    // 3. Fallback final para a thumb se a lista ainda estiver vazia
    if (fetchedImages.isEmpty && deal.value!.thumb.isNotEmpty){
        fetchedImages.add(deal.value!.thumb);
        print("[DealDetailController] Usando thumb como fallback para o carrossel.");
    }

    if (fetchedImages.isEmpty) {
      print("[DealDetailController] Nenhuma imagem encontrada para o carrossel.");
    }
    
    gameImageUrls.assignAll(fetchedImages); // Atualiza a lista reativa de uma vez
    isLoadingImages.value = false;
  }

  // Getter para a URL da imagem (já inclui o proxy)
  String get displayImageUrl { 
    if (gameImageUrls.isNotEmpty) return gameImageUrls.first; // Usa a primeira do carrossel (que será a header.jpg se existir)
    
    // Fallback se o carrossel estiver vazio (não deveria acontecer com a lógica em _fetchGameScreenshots)
    if (deal.value == null || deal.value!.thumb.isEmpty) return '';
    final currentDeal = deal.value!;
    String imageUrlToUse = currentDeal.thumb;
    if (currentDeal.steamAppID != null && currentDeal.steamAppID!.isNotEmpty) {
      imageUrlToUse = 'https://steamcdn-a.akamaihd.net/steam/apps/${currentDeal.steamAppID}/header.jpg';
    }
    if (imageUrlToUse.isEmpty) return '';
    String encodedImageUrl = Uri.encodeComponent(imageUrlToUse);
    return "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl"; 
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