import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';

class DealsController extends GetxController {
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();

  var dealsList = <DealModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var currentPage = 0.obs;
  var canLoadMoreDeals = true.obs;

  // Estado para a busca
  var searchQuery = ''.obs;
  var isSearching = false.obs; // Para diferenciar o modo de busca do modo de navegação normal
  final TextEditingController searchTEC = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Carrega as promoções iniciais (sem busca)
    fetchDeals(isInitialLoad: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchTEC.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
        !isLoadingMore.value &&
        canLoadMoreDeals.value) {
      fetchDeals(isLoadMore: true); // Carrega mais, respeitando o estado de busca
    }
  }

  Future<void> fetchDeals({
    bool isInitialLoad = false, 
    bool isRefresh = false, 
    bool isLoadMore = false,
    String? specificTitleQuery, // Usado pela função de busca
  }) async {
    
    final currentSearchTerm = specificTitleQuery ?? (isSearching.value ? searchQuery.value : null);

    if (isInitialLoad || isRefresh) {
      currentPage.value = 0;
      dealsList.clear();
      canLoadMoreDeals.value = true; // Reseta para permitir carregar mais
      if (isRefresh && currentSearchTerm == null) { // Se for refresh da navegação normal
        isSearching.value = false;
        searchQuery.value = '';
        searchTEC.clear();
      }
      isLoading.value = true;
    } else if (isLoadMore) {
      if (isLoadingMore.value || !canLoadMoreDeals.value) return;
      isLoadingMore.value = true;
    } else { // Chamada genérica, provavelmente um novo filtro ou busca
      isLoading.value = true;
      currentPage.value = 0;
      dealsList.clear();
      canLoadMoreDeals.value = true;
    }
    
    print("[DealsController] Buscando promoções. Query: '$currentSearchTerm', Página: ${currentPage.value}");

    try {
      final newDeals = await _dealsApiProvider.getDeals(
        pageNumber: currentPage.value,
        title: currentSearchTerm, // Passa o termo de busca para o provider
        // Outros filtros como sortBy, storeID podem ser adicionados aqui
      );

      if (newDeals.isNotEmpty) {
        if (isInitialLoad || isRefresh || (isSearching.value && currentPage.value == 0 && specificTitleQuery != null)) {
          dealsList.assignAll(newDeals);
        } else if (isLoadMore) {
          dealsList.addAll(newDeals);
        }
        currentPage.value++;
      } else {
        if (isInitialLoad || isRefresh || (isSearching.value && currentPage.value == 0 && specificTitleQuery != null)) {
           dealsList.clear(); // Limpa se a primeira busca/carga não retornar nada
        }
        canLoadMoreDeals.value = false; // Não há mais promoções para esta query/página
        if (isSearching.value && specificTitleQuery != null && dealsList.isEmpty) {
           Get.snackbar("Busca Concluída", "Nenhuma promoção encontrada para '${searchQuery.value}'.", snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      print("[DealsController] Erro ao buscar promoções: $e");
      // Tratar erro
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void searchGamesByTitle(String title) {
    if (title.trim().isEmpty) {
      clearSearchAndFetchInitial();
      return;
    }
    searchQuery.value = title.trim();
    isSearching.value = true;
    fetchDeals(isInitialLoad: true, specificTitleQuery: searchQuery.value); // Força um recarregamento com a nova query
  }

  void clearSearchAndFetchInitial() {
    searchQuery.value = '';
    searchTEC.clear();
    isSearching.value = false;
    fetchDeals(isRefresh: true); // Volta para as promoções normais
  }

  Future<void> refreshDealsList() async {
    await fetchDeals(isRefresh: true, specificTitleQuery: isSearching.value ? searchQuery.value : null);
  }
}