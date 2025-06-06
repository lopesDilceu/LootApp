import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/store_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';
// import 'package:loot_app/app/services/user_preferences_service.dart';

class DealsController extends GetxController {
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();
  // final UserPreferencesService _prefsService = UserPreferencesService.to;

  var dealsList = <DealModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var currentPage = 0.obs;
  var canLoadMoreDeals = true.obs;

  final TextEditingController searchTEC = TextEditingController(); 
  var searchQuery = ''.obs; 
  var isSearching = false.obs; 

  var availableStores = <StoreModel>[].obs;
  var selectedStoreIDs = <String>[].obs;
  var selectedSortBy = 'Deal Rating'.obs;
  final List<String> sortOptions = [
    'Deal Rating', 'Title', 'Savings', 'Price', 'Metacritic', 'Release', 'Store', 'recent'
  ];
  final TextEditingController lowerPriceTEC = TextEditingController();
  final TextEditingController upperPriceTEC = TextEditingController();

  final ScrollController scrollController = ScrollController();
  

  @override
  void onInit() {
    super.onInit();
    print("[DealsController] onInit chamado.");
    fetchStoresForFilter();
    fetchDeals(isInitialLoad: true); 
    scrollController.addListener(_onScroll);

    searchTEC.addListener(() {
      // Atualiza searchQuery apenas se o texto realmente mudou
      // para evitar loops ou atualizações desnecessárias.
      if (searchQuery.value != searchTEC.text) {
        searchQuery.value = searchTEC.text;
        // Não precisa chamar fetchDeals aqui, apenas atualiza o estado para o Obx do suffixIcon
        // A busca real acontece no onSubmitted ou no botão de busca.
      }
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
    final stores = await _dealsApiProvider.getStores();
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
      final newDeals = await _dealsApiProvider.getDeals(
        pageNumber: currentPage.value,
        title: currentSearchTerm,
        storeIDs: selectedStoreIDs.isEmpty ? null : List<String>.from(selectedStoreIDs),
        sortBy: selectedSortBy.value,
        lowerPrice: lowerPriceTEC.text.trim().isEmpty ? null : lowerPriceTEC.text.trim(),
        upperPrice: upperPriceTEC.text.trim().isEmpty ? null : upperPriceTEC.text.trim(),
      );
      if (newDeals.isNotEmpty) {
        if (isNewContext) dealsList.assignAll(newDeals);
        else dealsList.addAll(newDeals);
        currentPage.value++;
        if (newDeals.length < 30) canLoadMoreDeals.value = false; 
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
  Future<void> refreshDealsList() async { await fetchDeals(isRefresh: true); }
}