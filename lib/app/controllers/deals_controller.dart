import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/store_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';

class DealsController extends GetxController {
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();

  // Estados para a lista de promoções e paginação
  var dealsList = <DealModel>[].obs;
  var isLoading = true.obs; // Loader principal para novas buscas/filtros/refresh
  var isLoadingMore = false.obs; // Loader para paginação
  var currentPage = 0.obs;
  var canLoadMoreDeals = true.obs;

  // Estados para a busca por texto
  final TextEditingController searchTEC = TextEditingController();
  var searchQuery = ''.obs; // O termo de busca atual
  var isSearching = false.obs; // Indica se uma busca por texto está ativa

  // Estados para filtros adicionais
  var availableStores = <StoreModel>[].obs;
  var selectedStoreIDs = <String>[].obs;
  var selectedSortBy = 'Deal Rating'.obs; // Valor padrão de ordenação
  final List<String> sortOptions = [
    'Deal Rating', 'Title', 'Savings', 'Price', 'Metacritic', 'Release', 'Store', 'recent'
  ].obs;
  final TextEditingController lowerPriceTEC = TextEditingController();
  final TextEditingController upperPriceTEC = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    print("[DealsController] onInit chamado.");
    fetchStoresForFilter(); // Busca as lojas para o filtro
    fetchDeals(isInitialLoad: true); // Carga inicial de promoções
    scrollController.addListener(_onScroll);
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
    // Condição para carregar mais itens ao chegar perto do fim da lista
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
        !isLoadingMore.value &&
        canLoadMoreDeals.value) {
      fetchDeals(isLoadMore: true);
    }
  }

  Future<void> fetchStoresForFilter() async {
    print("[DealsController] Buscando lojas para filtro...");
    final stores = await _dealsApiProvider.getStores();
    if (stores.isNotEmpty) {
      availableStores.assignAll(stores);
    }
  }

  // Método central para buscar promoções, considerando busca e filtros
  Future<void> fetchDeals({
    bool isInitialLoad = false, // Primeira carga da tela
    bool isRefresh = false,     // Usuário puxou para atualizar
    bool isLoadMore = false,    // Carregando próxima página
  }) async {
    // Determina se é uma nova operação de busca que deve limpar a lista existente
    bool isNewContext = isInitialLoad || isRefresh;

    if (isNewContext) {
      currentPage.value = 0; // Reseta a página para uma nova busca/refresh
      dealsList.clear();     // Limpa promoções antigas
      canLoadMoreDeals.value = true; // Permite carregar mais novamente
      isLoading.value = true;  // Ativa o loader principal
    } else if (isLoadMore) {
      if (isLoadingMore.value || !canLoadMoreDeals.value) return; // Evita chamadas duplicadas
      isLoadingMore.value = true; // Ativa o loader de "carregar mais"
    }
    // Se não for isInitialLoad, isRefresh, ou isLoadMore, assume-se uma chamada genérica
    // que também deve resetar (ex: aplicação de um novo filtro via applyFilters)
    // A lógica acima já cobre isso se isNewContext for true.

    final String? currentSearchTerm = searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim();

    // print("[DealsController] Buscando promoções. Query: '$currentSearchTerm', Página: ${currentPage.value}, Lojas: ${selectedStoreIDs.value}, Ordenação: ${selectedSortBy.value}, Preço: ${lowerPriceTEC.text}-${upperPriceTEC.text}");

    try {
      final dealsData = await _dealsApiProvider.getDeals(
        pageNumber: currentPage.value,
        title: currentSearchTerm,
        storeIDs: selectedStoreIDs.isEmpty ? null : List<String>.from(selectedStoreIDs),
        sortBy: selectedSortBy.value,
        lowerPrice: lowerPriceTEC.text.trim().isEmpty ? null : lowerPriceTEC.text.trim(),
        upperPrice: upperPriceTEC.text.trim().isEmpty ? null : upperPriceTEC.text.trim(),
      );

      if (dealsData.isNotEmpty) {
        if (isNewContext) {
          dealsList.assignAll(dealsData);
        } else { // isLoadMore
          dealsList.addAll(dealsData);
        }
        currentPage.value++;
        // Heurística simples para canLoadMoreDeals: se retornou menos que o esperado, provavelmente não há mais.
        // Adapte o '30' para o seu pageSize real usado no DealsApiProvider.
        if (dealsData.length < 30) { 
          canLoadMoreDeals.value = false;
        }
      } else {
        if (isNewContext) {
          dealsList.clear(); // Garante que a lista esteja vazia se a nova busca não tiver resultados
        }
        canLoadMoreDeals.value = false; // Não há mais promoções para carregar
        if (isNewContext && dealsList.isEmpty && (currentSearchTerm != null || selectedStoreIDs.isNotEmpty || lowerPriceTEC.text.isNotEmpty || upperPriceTEC.text.isNotEmpty)) {
          Get.snackbar("Sem Resultados", "Nenhuma promoção encontrada para os critérios atuais.", snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      print("[DealsController] Erro ao buscar promoções: $e");
      Get.snackbar("Erro", "Falha ao buscar promoções. Verifique sua conexão.", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Método chamado pela UI ao submeter o texto de busca
  void searchGamesByTitle(String title) {
    print("[DealsController] searchGamesByTitle chamado com: '$title'");
    searchTEC.text = title.trim(); // Sincroniza o TextEditingController se chamado externamente
    searchQuery.value = title.trim();
    isSearching.value = searchQuery.value.isNotEmpty; // Atualiza o estado de busca
    fetchDeals(isInitialLoad: true); // Faz uma nova busca (reseta página e lista)
  }

  // Método chamado pela UI para limpar o campo de busca e recarregar
  void clearSearchAndFetchInitial() {
    print("[DealsController] clearSearchAndFetchInitial chamado");
    searchQuery.value = '';
    searchTEC.clear();
    isSearching.value = false;
    // Recarrega promoções com os filtros atuais (sem o termo de busca por texto)
    fetchDeals(isInitialLoad: true); 
  }
  
  // Método chamado pelo widget de filtro ao clicar em "Aplicar Filtros"
  void applyFilters() {
    print("[DealsController] Aplicando filtros - Lojas: ${selectedStoreIDs.join(',')}, Ordenação: ${selectedSortBy.value}, Preço: ${lowerPriceTEC.text}-${upperPriceTEC.text}, Busca por Texto: '${searchQuery.value}'");
    // O estado de isSearching é determinado pelo searchQuery
    isSearching.value = searchQuery.value.isNotEmpty; 
    fetchDeals(isInitialLoad: true); // Requisita uma nova lista de promoções com todos os filtros e busca atuais
  }
  
  // Método chamado pelo widget de filtro ao clicar em "Limpar Tudo"
  void clearAllFilters() {
    print("[DealsController] Limpando todos os filtros e query de busca.");
    selectedStoreIDs.clear();
    selectedSortBy.value = 'Deal Rating'; // Volta para o padrão
    lowerPriceTEC.clear();
    upperPriceTEC.clear();
    searchQuery.value = ''; // Limpa também o termo de busca por texto
    searchTEC.clear();
    isSearching.value = false;
    fetchDeals(isInitialLoad: true); // Busca promoções sem filtros e sem busca por texto
  }

  // Para o RefreshIndicator na UI
  Future<void> refreshDealsList() async {
    print("[DealsController] Atualizando lista de promoções (pull-to-refresh)...");
    // A flag isRefresh dentro de fetchDeals vai resetar a paginação e limpar a lista
    await fetchDeals(isRefresh: true); 
  }
}