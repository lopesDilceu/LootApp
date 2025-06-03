import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/providers/deals_api_provider.dart'; // Para buscar promoções
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class HomeController extends GetxController {
  // Injeta o DealsApiProvider. Ele será fornecido pelo HomeBinding.
  final DealsApiProvider _dealsApiProvider = Get.find<DealsApiProvider>();
  // Acesso ao AuthService para a UI reagir
  final AuthService authService = AuthService.to;

  var topDeals = <DealModel>[].obs; // Lista reativa para promoções da home
  var isLoadingDeals = true.obs;

  late PageController carouselPageController;
  var currentCarouselIndex = 0.obs;
  Timer? _carouselTimer;

  @override
  void onInit() {
    super.onInit();
    print("[HomeController] onInit chamado");
    
    carouselPageController = PageController(viewportFraction: 0.85); 
    fetchHomepageDeals();
  }

  @override
  void onClose() {
    print("[HomeController] onClose chamado");
    carouselPageController.dispose();
    _carouselTimer?.cancel();
    super.onClose();
  }

    void _startCarouselAutoScroll() {
    _carouselTimer?.cancel(); // Cancela timer anterior se existir
    if (topDeals.length > 1) { // Só faz auto-scroll se houver mais de um item
      _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (currentCarouselIndex.value < topDeals.length - 1) {
          currentCarouselIndex.value++;
        } else {
          currentCarouselIndex.value = 0; // Volta para o início
        }
        if (carouselPageController.hasClients) {
          carouselPageController.animateToPage(
            currentCarouselIndex.value,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInQuint, // Curva de animação suave
          );
        }
      });
    }
  }

  Future<void> fetchHomepageDeals() async {
    print("[HomeController] Buscando promoções para a Home...");
    isLoadingDeals.value = true;
    _carouselTimer?.cancel(); // Para o auto-scroll durante o carregamento

    try {
      // Busca um número limitado de promoções, talvez as mais recentes ou com maior avaliação/desconto
      final deals = await _dealsApiProvider.getDeals(pageSize: 6, sortBy: 'Deal Rating'); // Ex: 6 melhores ofertas
      if (deals.isNotEmpty) {
        topDeals.assignAll(deals);
        print("[HomeController] ${deals.length} promoções da home carregadas.");
        currentCarouselIndex.value = 0;
        if (carouselPageController.hasClients) {
           carouselPageController.jumpToPage(0); // Garante que o PageView comece do início
        }
        _startCarouselAutoScroll();
      } else {
        print("[HomeController] Nenhuma promoção encontrada para a home.");
        topDeals.clear();
      }
    } catch (e) {
      print("[HomeController] Erro ao buscar promoções da home: $e");
      topDeals.clear();
      // Um snackbar aqui pode ser muito intrusivo para a home pública
    } finally {
      isLoadingDeals.value = false;
    }
  }

  void navigateToLogin() {
    print("[HomeController] navigateToLogin chamado");
    Get.toNamed(AppRoutes.LOGIN);
  }

  void navigateToDealsList() {
    print("[HomeController] navigateToDealsList chamado (usuário logado quer ver todas as promoções)");
    Get.toNamed(AppRoutes.MAIN_NAVIGATION, arguments: {'initialTabIndex': 1});
  }

  // Para o RefreshIndicator
  Future<void> refreshHomepageDeals() async {
    await fetchHomepageDeals();
  }
}