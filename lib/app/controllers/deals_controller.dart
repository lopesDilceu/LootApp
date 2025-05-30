// lib/app/controllers/deals_controller.dart
import 'package:flutter/material.dart'; // Para ScrollController e Colors
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart';

class DealsController extends GetxController {
  // Injeta o DealsApiProvider (deve estar registrado no DealsBinding ou globalmente)
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();

  var dealsList = <DealModel>[].obs; // Lista reativa de promoções
  var isLoading = true.obs; // Para o carregamento inicial
  var isLoadingMore = false.obs; // Para carregamento de mais itens na paginação
  var currentPage = 0.obs;
  var canLoadMoreDeals = true.obs; // Flag para saber se há mais páginas para carregar

  final ScrollController scrollController = ScrollController(); // Para o scroll infinito

  @override
  void onInit() {
    super.onInit();
    fetchInitialDeals(); // Busca as promoções iniciais
    scrollController.addListener(_onScroll); // Adiciona listener para o scroll
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose(); // Libera o ScrollController
    super.onClose();
  }

  void _onScroll() {
    // Verifica se chegou ao final da lista, não está carregando mais e ainda pode carregar mais
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && // Trigger um pouco antes do final
        !isLoadingMore.value &&
        canLoadMoreDeals.value) {
      fetchMoreDeals();
    }
  }

  Future<void> fetchInitialDeals() async {
    isLoading.value = true;
    canLoadMoreDeals.value = true; // Reseta para permitir carregar mais
    currentPage.value = 0; // Reseta a página
    dealsList.clear(); // Limpa a lista para um refresh completo
    print("[DealsController] Buscando promoções iniciais...");
    try {
      final newDeals = await _dealsApiProvider.getDeals(pageNumber: currentPage.value);
      if (newDeals.isNotEmpty) {
        dealsList.assignAll(newDeals);
        currentPage.value++; // Prepara para a próxima página
      } else {
        // Nenhuma promoção encontrada na primeira busca ou API retornou vazio
        canLoadMoreDeals.value = false;
        print("[DealsController] Nenhuma promoção inicial encontrada.");
      }
    } catch (e) {
      print("[DealsController] Erro ao buscar promoções iniciais: $e");
      // O provider já mostra um snackbar, mas você pode adicionar um específico aqui se quiser
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreDeals() async {
    if (isLoadingMore.value || !canLoadMoreDeals.value) return; // Evita múltiplas chamadas

    isLoadingMore.value = true;
    print("[DealsController] Buscando mais promoções, página: ${currentPage.value}");
    try {
      final newDeals = await _dealsApiProvider.getDeals(pageNumber: currentPage.value);
      if (newDeals.isNotEmpty) {
        dealsList.addAll(newDeals);
        currentPage.value++;
      } else {
        print("[DealsController] Não há mais promoções para carregar.");
        canLoadMoreDeals.value = false; // Indica que não há mais páginas
      }
    } catch (e) {
      print("[DealsController] Erro ao buscar mais promoções: $e");
      // Para "carregar mais", um snackbar pode ser intrusivo, talvez apenas um log.
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Método para ser chamado pelo Pull-to-Refresh na UI
  Future<void> refreshDeals() async {
    print("[DealsController] Atualizando promoções (pull-to-refresh)...");
    await fetchInitialDeals();
  }

  // TODO: Adicionar métodos para filtros (por loja, por nome do jogo, etc.)
  // void filterByStore(String storeId) { ... }
  // void searchDeals(String query) { ... }
}