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

  @override
  void onInit() {
    super.onInit();
    print("[HomeController] onInit chamado");
    fetchHomepageDeals();
  }

  Future<void> fetchHomepageDeals() async {
    print("[HomeController] Buscando promoções para a Home...");
    isLoadingDeals.value = true;
    try {
      // Busca um número limitado de promoções, talvez as mais recentes ou com maior avaliação/desconto
      final deals = await _dealsApiProvider.getDeals(pageSize: 6, sortBy: 'Deal Rating'); // Ex: 6 melhores ofertas
      if (deals.isNotEmpty) {
        topDeals.assignAll(deals);
        print("[HomeController] ${deals.length} promoções da home carregadas.");
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
    Get.toNamed(AppRoutes.DEALS_LIST);
  }

  // Para o RefreshIndicator
  Future<void> refreshHomepageDeals() async {
    await fetchHomepageDeals();
  }
}