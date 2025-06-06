import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/ggd_models.dart';
import 'package:loot_app/app/data/models/store_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';
import 'package:loot_app/app/data/providers/ggd_api_provider.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';
// import 'package:loot_app/app/services/user_preferences_service.dart';

class DealsController extends GetxController {
  final DealsApiProvider _cheapSharkApiProvider = Get.find<DealsApiProvider>();
  final GGDotDealsApiProvider _ggdApiProvider = Get.find<GGDotDealsApiProvider>();
  final UserPreferencesService _prefsService = UserPreferencesService.to;

  var dealsList = <DealModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var currentPage = 0.obs;
  var canLoadMoreDeals = true.obs;

  final TextEditingController searchTEC = TextEditingController(); 
  var searchQuery = ''.obs; 
  var isSearching = false.obs; 

  var availableStoresCS = <StoreModel>[].obs;
  var selectedStoreIDsCS = <String>[].obs;

  var availableStores = <StoreModel>[].obs;
  var selectedStoreIDs = <String>[].obs;
  var selectedSortBy = 'Deal Rating'.obs;
  final List<String> sortOptions = [
    'Deal Rating', 'Title', 'Savings', 'Price', 'Metacritic', 'Release', 'Store', 'recent'
  ];
  final TextEditingController lowerPriceTEC = TextEditingController();
  final TextEditingController upperPriceTEC = TextEditingController();

  final ScrollController scrollController = ScrollController();
  RxList<GGDShopInfo> _ggdShops = <GGDShopInfo>[].obs; // Cache de lojas da GG.deals
  var isLoadingGGDShops = false.obs;  

  @override
  void onInit() {
    super.onInit();
    print("[DealsController] onInit chamado.");
    _loadGGDShopsAndThenFetchInitialDeals();
    scrollController.addListener(_onScroll);
    ever(_prefsService.selectedCountryCode, (_) => _refetchAllRegionalPrices());
    searchTEC.addListener(() {
      if (searchQuery.value != searchTEC.text) searchQuery.value = searchTEC.text;
    });
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchTEC.dispose(); 
    lowerPriceTEC.dispose();
    upperPriceTEC.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
        !isLoadingMore.value &&
        canLoadMoreDeals.value) {
      fetchDeals(isLoadMore: true);
    }
  }
  
  Future<void> fetchStoresForFilter() async {
    print("[DealsController] Buscando lojas para filtro...");
    final stores = await _cheapSharkApiProvider.getStores();
    if (stores.isNotEmpty) availableStores.assignAll(stores);
  }

  Future<void> fetchDeals({
    bool isInitialLoad = false, 
    bool isRefresh = false, 
    bool isLoadMore = false,
  }) async {
    bool isNewContext = isInitialLoad || isRefresh;
    if (isNewContext) { 
        currentPage.value = 0;
        dealsList.clear();
        canLoadMoreDeals.value = true;
        isLoading.value = true;
    } 
    else if (isLoadMore) { 
        if (isLoadingMore.value || !canLoadMoreDeals.value) return;
        isLoadingMore.value = true;
    }
    
    final String? currentSearchTerm = searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();
    print("[DealsController] Buscando promoções. Query: '$currentSearchTerm', Página: ${currentPage.value}, Filtros: ...");

    try {
      final cheapSharkDeals = await _cheapSharkApiProvider.getDeals(
        pageNumber: currentPage.value,
        title: currentSearchTerm,
        storeIDs: selectedStoreIDs.isEmpty ? null : List<String>.from(selectedStoreIDs),
        sortBy: selectedSortBy.value,
        lowerPrice: lowerPriceTEC.text.trim().isEmpty ? null : lowerPriceTEC.text.trim(),
        upperPrice: upperPriceTEC.text.trim().isEmpty ? null : upperPriceTEC.text.trim(),
      );
      if (cheapSharkDeals.isNotEmpty) {
        if (isNewContext) dealsList.assignAll(cheapSharkDeals);
        else dealsList.addAll(cheapSharkDeals);
        _enrichDealsWithRegionalPrices(isNewContext ? dealsList : cheapSharkDeals); 
        currentPage.value++;
        if (cheapSharkDeals.length < 30) canLoadMoreDeals.value = false; 
      } else {
        if (isNewContext) dealsList.clear();
        canLoadMoreDeals.value = false;
        if (isNewContext && dealsList.isEmpty && (currentSearchTerm != null || selectedStoreIDs.isNotEmpty)) {
          Get.snackbar("Sem Resultados", "Nenhuma promoção para os critérios.", snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) { 
        print("[DealsController] Erro ao buscar promoções: $e");
        Get.snackbar("Erro", "Falha ao buscar promoções.", snackPosition: SnackPosition.BOTTOM);
    } 
    finally { isLoading.value = false; isLoadingMore.value = false; }
  }

  void searchGamesByTitleInScreen(String title) {
    print("[DealsController] Busca do corpo da tela: '$title'");
    searchQuery.value = title.trim(); 
    isSearching.value = searchQuery.value.isNotEmpty;
    fetchDeals(isInitialLoad: true); 
  }

  void clearSearchInScreenAndFetchInitial() {
    print("[DealsController] Limpando busca do corpo da tela.");
    searchQuery.value = '';
    searchTEC.clear(); 
    isSearching.value = false;
    fetchDeals(isInitialLoad: true);
  }
  
  void applyFilters() { 
    print("[DealsController] Aplicando filtros...");
    fetchDeals(isInitialLoad: true);
  }
  void clearAllFilters() { 
    print("[DealsController] Limpando filtros...");
    selectedStoreIDs.clear();
    selectedSortBy.value = 'Deal Rating';
    lowerPriceTEC.clear();
    upperPriceTEC.clear();
    // Não limpa searchQuery aqui, para permitir limpar filtros mantendo a busca por texto
    fetchDeals(isInitialLoad: true);
  }

  Future<void> _loadGGDShopsAndThenFetchInitialDeals() async {
    isLoadingGGDShops.value = true;
    await _loadGGDShops();
    isLoadingGGDShops.value = false;
    fetchDeals(isInitialLoad: true); // Busca deals da CheapShark
  }

  Future<void> _loadGGDShops() async {
    if (_ggdShops.isNotEmpty) return;
    final shops = await _ggdApiProvider.getShops();
    if (shops.isNotEmpty) _ggdShops.assignAll(shops);
    else print("[DealsController] Nenhuma loja da GG.deals carregada.");
  }

  Future<void> _enrichDealsWithRegionalPrices(List<DealModel> dealsToEnrich) async {
    if (_ggdShops.isEmpty && !isLoadingGGDShops.value) { // Tenta carregar se estiver vazia e não carregando
      print("[DealsController] Tentando carregar lojas GG.deals antes de enriquecer...");
      await _loadGGDShops();
    }
    if (_ggdShops.isEmpty) {
        print("[DealsController] Lista de lojas GG.deals vazia. Não é possível enriquecer.");
        dealsToEnrich.forEach((d) => d.updateWithGGDPrice(null));
        return;
    }
    String countryCode = _prefsService.selectedCountryCode.value;
    print("[DealsController] Enriquecendo ${dealsToEnrich.length} deals para país: $countryCode");

    for (var deal in dealsToEnrich) {
      if (deal.regionalPriceFetched.value && !deal.isLoadingRegionalPrice.value) continue;
      // Não precisa de await aqui, deixa as buscas de preço para cada card rodarem em paralelo
      _fetchAndApplySingleDealRegionalPrice(deal, countryCode);
    }
  }

  Future<void> _fetchAndApplySingleDealRegionalPrice(DealModel deal, String countryCode) async {
    if (deal.isLoadingRegionalPrice.value) return; // Já está buscando
    deal.isLoadingRegionalPrice.value = true;
    GGDShopPrice? ggdPriceInfo;

    try {
      String? plain = await _ggdApiProvider.getPlainForGame(steamAppId: deal.steamAppID, title: deal.title);
      if (plain == null) { deal.updateWithGGDPrice(null); return; }

      String? cheapSharkStoreNameUpper = deal.storeName.toUpperCase();
      // Mapeamento de ID da loja da CheapShark para ID da loja da GG.deals
      String? ggdShopId;
      switch (deal.storeID) { // Mapeia pelo ID da CheapShark que é mais confiável
        case '1': ggdShopId = 'steam'; break;
        case '7': ggdShopId = 'gog'; break;
        case '25': ggdShopId = 'epic'; break; // Epic Games Store
        case '11': ggdShopId = 'humblestore'; break;
        case '2': ggdShopId = 'gamersgate'; break;
        case '3': ggdShopId = 'greenmangaming'; break;
        // Adicione mais mapeamentos diretos baseados nos IDs da CheapShark
        // e os IDs correspondentes da GG.deals (que você pode ver em _ggdShops)
        default: // Tenta mapear pelo nome se não houver ID direto
          var foundShop = _ggdShops.firstWhereOrNull((s) => s.title.toUpperCase() == cheapSharkStoreNameUpper);
          ggdShopId = foundShop?.id;
      }
      
      if (ggdShopId == null) {
        print("[DealsController] Loja não mapeada para GG.deals: ${deal.storeName} (CS ID: ${deal.storeID})");
        deal.updateWithGGDPrice(null); return;
      }

      ggdPriceInfo = await _ggdApiProvider.getRegionalPriceForShop(
        plain: plain, countryCode: countryCode, shopId: ggdShopId,
      );
    } catch (e) {
      print("[DealsController] Exceção em _fetchAndApplySingleDealRegionalPrice para ${deal.title}: $e");
    } finally {
      if (!isClosed) deal.updateWithGGDPrice(ggdPriceInfo);
    }
  }

  Future<void> _refetchAllRegionalPrices() async {
    if (dealsList.isEmpty) return;
    print("[DealsController] País mudou. Refazendo busca de preços regionais para ${dealsList.length} promoções...");
    for (var deal in dealsList) {
      deal.regionalPriceFetched.value = false; // Permite nova busca
      deal.regionalPriceFormatted.value = null; // Limpa preço antigo
      // isLoadingRegionalPrice será setado por _fetchAndApplySingleDealRegionalPrice
    }
    await _enrichDealsWithRegionalPrices(List<DealModel>.from(dealsList)); // Cria uma nova lista para evitar modificar durante iteração
  }

  Future<void> refreshDealsList() async { await fetchDeals(isRefresh: true); }
}