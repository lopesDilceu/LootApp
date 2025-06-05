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
    gameImageUrls.clear(); // Limpa para nova busca

    int? rawgGameId;
    // Tenta encontrar o ID do jogo na RAWG
    if (deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
      // Se sua RawgApiProvider tiver um método para buscar por steamAppID:
      rawgGameId = await _rawgApiProvider.findRawgGameIdBySteamId(deal.value!.steamAppID!);
    }
    if (rawgGameId == null) { // Fallback para buscar por título
      rawgGameId = await _rawgApiProvider.findRawgGameIdByTitle(deal.value!.title);
    }
    
    if (rawgGameId != null) {
      final screenshots = await _rawgApiProvider.getGameScreenshots(rawgGameId);
      if (screenshots.isNotEmpty) {
        gameImageUrls.assignAll(screenshots);
        print("[DealDetailController] ${screenshots.length} screenshots da RAWG carregadas.");
      }
    }
    
    // Fallback se não encontrar screenshots da RAWG, mas tiver steamAppID para header
    if (gameImageUrls.isEmpty && deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
        gameImageUrls.add('https://steamcdn-a.akamaihd.net/steam/apps/${deal.value!.steamAppID}/header.jpg');
    }
    // Fallback final para a thumb se tudo mais falhar
    if (gameImageUrls.isEmpty && deal.value!.thumb.isNotEmpty){
        gameImageUrls.add(deal.value!.thumb);
    }
    if (gameImageUrls.isEmpty) {
      print("[DealDetailController] Nenhuma imagem encontrada para o carrossel.");
    }

    isLoadingImages.value = false;
  }

  // Getter para a URL da imagem (já inclui o proxy)
  String get displayImageUrl { // Esta pode ser a imagem principal ANTES do carrossel
    if (deal.value == null) return '';
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