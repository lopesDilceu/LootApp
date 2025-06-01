import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/ggd_model.dart';
import 'package:loot_app/app/data/models/store_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';
import 'package:loot_app/app/data/providers/ggd_api_provider.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';

class DealsController extends GetxController {
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();

  // Estados para a lista de promoções e paginação
  var dealsList = <DealModel>[].obs;
  var isLoading =
      true.obs; // Loader principal para novas buscas/filtros/refresh
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
    'Deal Rating',
    'Title',
    'Savings',
    'Price',
    'Metacritic',
    'Release',
    'Store',
    'recent',
  ].obs;
  final TextEditingController lowerPriceTEC = TextEditingController();
  final TextEditingController upperPriceTEC = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final GGDotDealsApiProvider _ggdApiProvider =
      Get.find<GGDotDealsApiProvider>();
  final UserPreferencesService _prefsService = UserPreferencesService.to;
  RxList<GGDShopInfo> ggdShops = <GGDShopInfo>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("[DealsController] onInit chamado.");
    _loadGGDShops();
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
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 300 &&
        !isLoadingMore.value &&
        canLoadMoreDeals.value) {
      fetchDeals(isLoadMore: true);
    }
  }

  Future<void> _loadGGDShops() async {
    if (ggdShops.isNotEmpty) return; // Evita recarregar se já tiver
    print("[DealsController] Carregando lojas da GG.deals...");
    final shops = await _ggdApiProvider.getShops();
    if (shops.isNotEmpty) {
      ggdShops.assignAll(shops);
      print(
        "[DealsController] ${ggdShops.length} lojas da GG.deals carregadas.",
      );
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
    bool isRefresh = false, // Usuário puxou para atualizar
    bool isLoadMore = false, // Carregando próxima página
  }) async {
    // Determina se é uma nova operação de busca que deve limpar a lista existente
    bool isNewContext = isInitialLoad || isRefresh;

    if (isNewContext) {
      currentPage.value = 0; // Reseta a página para uma nova busca/refresh
      dealsList.clear(); // Limpa promoções antigas
      canLoadMoreDeals.value = true; // Permite carregar mais novamente
      isLoading.value = true; // Ativa o loader principal
    } else if (isLoadMore) {
      if (isLoadingMore.value || !canLoadMoreDeals.value)
        return; // Evita chamadas duplicadas
      isLoadingMore.value = true; // Ativa o loader de "carregar mais"
    }
    // Se não for isInitialLoad, isRefresh, ou isLoadMore, assume-se uma chamada genérica
    // que também deve resetar (ex: aplicação de um novo filtro via applyFilters)
    // A lógica acima já cobre isso se isNewContext for true.

    final String? currentSearchTerm = searchQuery.value.trim().isEmpty
        ? null
        : searchQuery.value.trim();

    // print("[DealsController] Buscando promoções. Query: '$currentSearchTerm', Página: ${currentPage.value}, Lojas: ${selectedStoreIDs.value}, Ordenação: ${selectedSortBy.value}, Preço: ${lowerPriceTEC.text}-${upperPriceTEC.text}");

    try {
      final dealsData = await _dealsApiProvider.getDeals(
        pageNumber: currentPage.value,
        title: currentSearchTerm,
        storeIDs: selectedStoreIDs.isEmpty
            ? null
            : List<String>.from(selectedStoreIDs),
        sortBy: selectedSortBy.value,
        lowerPrice: lowerPriceTEC.text.trim().isEmpty
            ? null
            : lowerPriceTEC.text.trim(),
        upperPrice: upperPriceTEC.text.trim().isEmpty
            ? null
            : upperPriceTEC.text.trim(),
      );

      if (dealsData.isNotEmpty) {
        if (isNewContext) {
          dealsList.assignAll(dealsData);
        } else {
          // isLoadMore
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
          dealsList
              .clear(); // Garante que a lista esteja vazia se a nova busca não tiver resultados
        }
        canLoadMoreDeals.value = false; // Não há mais promoções para carregar
        if (isNewContext &&
            dealsList.isEmpty &&
            (currentSearchTerm != null ||
                selectedStoreIDs.isNotEmpty ||
                lowerPriceTEC.text.isNotEmpty ||
                upperPriceTEC.text.isNotEmpty)) {
          Get.snackbar(
            "Sem Resultados",
            "Nenhuma promoção encontrada para os critérios atuais.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print("[DealsController] Erro ao buscar promoções: $e");
      Get.snackbar(
        "Erro",
        "Falha ao buscar promoções. Verifique sua conexão.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Método chamado pela UI ao submeter o texto de busca
  void searchGamesByTitle(String title) {
    print("[DealsController] searchGamesByTitle chamado com: '$title'");
    searchTEC.text = title
        .trim(); // Sincroniza o TextEditingController se chamado externamente
    searchQuery.value = title.trim();
    isSearching.value =
        searchQuery.value.isNotEmpty; // Atualiza o estado de busca
    fetchDeals(
      isInitialLoad: true,
    ); // Faz uma nova busca (reseta página e lista)
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
    print(
      "[DealsController] Aplicando filtros - Lojas: ${selectedStoreIDs.join(',')}, Ordenação: ${selectedSortBy.value}, Preço: ${lowerPriceTEC.text}-${upperPriceTEC.text}, Busca por Texto: '${searchQuery.value}'",
    );
    // O estado de isSearching é determinado pelo searchQuery
    isSearching.value = searchQuery.value.isNotEmpty;
    fetchDeals(
      isInitialLoad: true,
    ); // Requisita uma nova lista de promoções com todos os filtros e busca atuais
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
    fetchDeals(
      isInitialLoad: true,
    ); // Busca promoções sem filtros e sem busca por texto
  }

  // Para o RefreshIndicator na UI
  Future<void> refreshDealsList() async {
    print(
      "[DealsController] Atualizando lista de promoções (pull-to-refresh)...",
    );
    // A flag isRefresh dentro de fetchDeals vai resetar a paginação e limpar a lista
    await fetchDeals(isRefresh: true);
  }

  Future<void> _enrichGivenDealsWithRegionalPrices(
    List<DealModel> dealsToEnrich,
  ) async {
    if (dealsToEnrich.isEmpty || ggdShops.isEmpty) {
      // Precisa das lojas da GG.deals para mapear
      if (ggdShops.isEmpty)
        print(
          "[DealsController] Lista de lojas GG.deals vazia, não é possível enriquecer.",
        );
      // Marca os deals como "tentativa de busca de preço regional concluída" mesmo se não puder buscar
      for (var deal in dealsToEnrich) {
        if (!deal.regionalPriceFetched.value) {
          // Só atualiza se não foi tentado antes
          deal.updateWithGGDPrice(null);
        }
      }
      return;
    }
    String countryCode = _prefsService.selectedCountryCode.value;
    print(
      "[DealsController] Enriquecendo ${dealsToEnrich.length} promoções com preços para o país: $countryCode",
    );

    for (var deal in dealsToEnrich) {
      // Não precisa setar isLoadingRegionalPrice aqui se _fetchAndApplySingleDealRegionalPrice fizer
      _fetchAndApplySingleDealRegionalPrice(deal, countryCode);
    }
  }

  Future<void> _reFetchRegionalPricesForAllDealsInList() async {
    if (dealsList.isEmpty) return;

    // Marca todos para nova busca de preço regional
    for (var deal in dealsList) {
      deal.regionalPriceFetched.value = false;
      deal.regionalPriceFormatted.value = null;
      // isLoadingRegionalPrice será setado por _fetchAndApplySingleDealRegionalPrice
    }
    // Agora, enriquece todos novamente
    await _enrichGivenDealsWithRegionalPrices(List<DealModel>.from(dealsList));
  }

  // Lógica para buscar e aplicar preço regional para UM ÚNICO deal
  Future<void> _fetchAndApplySingleDealRegionalPrice(
    DealModel deal,
    String countryCode,
  ) async {
    if (deal.regionalPriceFetched.value && !deal.isLoadingRegionalPrice.value)
      return; // Já buscou ou está buscando

    deal.isLoadingRegionalPrice.value = true;
    GGDShopPrice? ggdPriceInfo;

    try {
      String? plain;
      if (deal.steamAppID != null && deal.steamAppID!.isNotEmpty) {
        plain = await _ggdApiProvider.getPlainForGame(
          steamAppId: deal.steamAppID,
        );
      }
      if (plain == null || plain.isEmpty) {
        plain = await _ggdApiProvider.getPlainForGame(title: deal.title);
      }

      if (plain == null || plain.isEmpty) {
        deal.updateWithGGDPrice(null);
        return;
      }

      String? cheapSharkStoreName = deal.storeName.toUpperCase();
      String? ggdShopId;
      var foundShop = ggdShops.firstWhereOrNull(
        (s) =>
            s.title.toUpperCase() == cheapSharkStoreName ||
            s.id.toUpperCase() == cheapSharkStoreName ||
            (cheapSharkStoreName.contains("STEAM") &&
                s.id.toUpperCase() == "STEAM") ||
            (cheapSharkStoreName.contains("GOG") &&
                s.id.toUpperCase() == "GOG"),
      );
      ggdShopId = foundShop?.id;

      if (ggdShopId == null) {
        deal.updateWithGGDPrice(null);
        return;
      }

      ggdPriceInfo = await _ggdApiProvider.getRegionalPriceForShop(
        plain: plain,
        countryCode: countryCode,
        shopId: ggdShopId,
      );
    } catch (e) {
      print(
        "[DealsController] Exceção em _fetchAndApplySingleDealRegionalPrice para ${deal.title}: $e",
      );
    } finally {
      // updateWithGGDPrice lida com isLoadingRegionalPrice = false e regionalPriceFetched = true
      deal.updateWithGGDPrice(ggdPriceInfo);
    }
  }
}
