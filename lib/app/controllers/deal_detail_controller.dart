import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/ggd_model.dart';
import 'package:loot_app/app/data/providers/ggd_api_provider.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir o link da promoção

class DealDetailController extends GetxController {
  final Rxn<DealModel> deal = Rxn<DealModel>();

  final GGDotDealsApiProvider _ggdApiProvider = Get.find<GGDotDealsApiProvider>();
  final UserPreferencesService _prefsService = UserPreferencesService.to;

  
  final Map<String, String> _storeNameToGGDShopId = {
    'STEAM': 'steam',
    'GOG': 'gog',
    'HUMBLE STORE': 'humblestore', // Verifique o ID exato da GG.deals para Humble
    'EPIC GAMES STORE': 'epic',
    'NUUVEM': 'nuuvem',
    // Adicione mais mapeamentos conforme os nomes retornados por deal.storeName
  };
  RxList<GGDShopInfo> ggdShops = <GGDShopInfo>[].obs;

  Future<void> _loadAllGGDShopsAndThenPrice() async {
    if (deal.value == null) return;
    deal.value!.isLoadingRegionalPrice.value = true;

    if (ggdShops.isEmpty) { // Busca lojas da GG.deals apenas uma vez
        final shops = await _ggdApiProvider.getShops();
        if (shops.isNotEmpty) ggdShops.assignAll(shops);
    }
    await fetchRegionalPriceForDeal();
  }

  // Getter para a URL da imagem que deve ser exibida na tela de detalhes
  String get displayImageUrl {
    if (deal.value == null) return '';

    final currentDeal = deal.value!;
    String imageUrlToUse = currentDeal.thumb;

    if (currentDeal.steamAppID != null && currentDeal.steamAppID!.isNotEmpty) {
      imageUrlToUse = 'https://steamcdn-a.akamaihd.net/steam/apps/${currentDeal.steamAppID}/header.jpg';
      print("[DealDetailController] Usando URL da Steam (header.jpg): $imageUrlToUse");
    } else {
      print("[DealDetailController] Sem steamAppID, usando thumbnail: $imageUrlToUse");
    }
    
    if (imageUrlToUse.isEmpty) return '';

    String encodedImageUrl = Uri.encodeComponent(imageUrlToUse);
    // VVVVVV USA A CONSTANTE AQUI VVVVVV
    final proxiedUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl"; 
    print("[DealDetailController] URL final do proxy para a imagem: $proxiedUrl");
    return proxiedUrl;
  }

  @override
  void onInit() {
    super.onInit();
    print("[DealDetailController] onInit. Argumentos: ${Get.arguments}");
    if (Get.arguments is DealModel) {
      deal.value = Get.arguments as DealModel; // Define o deal principal
      print("[DealDetailController] DealModel recebido: ${deal.value?.title}");

      if (deal.value != null) {
        // Adia a busca do preço regional para após o primeiro frame de build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Verifica se o controller ainda está montado/ativo
          if (isClosed) return; 
          print("[DealDetailController] addPostFrameCallback: Chamando _initiateRegionalPriceFetch");
          _initiateRegionalPriceFetch();
        });

        // Listener para mudanças de país (continua aqui, pois 'ever' lida bem com o timing)
        ever(_prefsService.selectedCountryCode, (String newCountryCode) {
          if (isClosed) return;
          print("[DealDetailController] Código do país mudou para: $newCountryCode. Recarregando preço regional.");
          if (deal.value != null) {
            deal.value!.regionalPriceFetched.value = false;
            deal.value!.regionalPriceFormatted.value = null;
            // Chama _initiateRegionalPriceFetch que já seta isLoadingRegionalPrice para true
            _initiateRegionalPriceFetch(); 
          }
        });
      }
    } else {
      print("ERRO: DealModel não foi passado como argumento para DealDetailScreen. Tipo: ${Get.arguments?.runtimeType}");
      Get.snackbar("Erro", "Não foi possível carregar os detalhes da promoção.");
      // Considerar Get.back() ou mostrar um estado de erro permanente na UI
    }
  }

  Future<void> _initiateRegionalPriceFetch() async {
    if (deal.value == null) return;
    
    // Define isLoading como true ANTES de qualquer await
    deal.value!.isLoadingRegionalPrice.value = true; 

    if (ggdShops.isEmpty && Get.isRegistered<DealsController>()) {
      // Tenta pegar as lojas já carregadas pelo DealsController para economizar uma chamada
      final dealsCtrl = Get.find<DealsController>();
      if (dealsCtrl.ggdShops.isNotEmpty) {
        ggdShops.assignAll(dealsCtrl.ggdShops);
        print("[DealDetailController] Lojas da GG.deals obtidas do DealsController.");
      }
    }
    // Se ainda estiverem vazias, busca (isso pode ser otimizado para não buscar sempre)
    if (ggdShops.isEmpty) {
        final shops = await _ggdApiProvider.getShops();
        if (shops.isNotEmpty) ggdShops.assignAll(shops);
    }
    
    // Agora chama o método que realmente busca o preço
    await _fetchAndApplyRegionalPrice();
  }

  // Método para abrir o link da promoção (como antes)
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

  Future<void> fetchRegionalPriceForDeal() async {
    if (deal.value == null || deal.value!.regionalPriceFetched.value) {
      if(deal.value != null) deal.value!.isLoadingRegionalPrice.value = false;
      return; // Já buscou ou não há deal
    }

    deal.value!.isLoadingRegionalPrice.value = true;
    String? plain;

    // 1. Obter o "plain" do jogo
    if (deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
      plain = await _ggdApiProvider.getPlainForGame(steamAppId: deal.value!.steamAppID);
    }
    if (plain == null || plain.isEmpty) { // Fallback para buscar por título se steamAppID falhar ou não existir
      plain = await _ggdApiProvider.getPlainForGame(title: deal.value!.title);
    }

    if (plain == null || plain.isEmpty) {
      print("[DealDetailController] Não foi possível encontrar o 'plain' para ${deal.value!.title}");
      deal.value!.updateWithGGDPrice(null); // Marca como tentado, mas falhou
      return;
    }
    print("[DealDetailController] Plain para ${deal.value!.title}: $plain");

    // 2. Mapear storeID da CheapShark para shopId da GG.deals
    // O deal.storeName vem do getter no seu DealModel da CheapShark
    String? cheapSharkStoreName = deal.value!.storeName.toUpperCase();
    String? ggdShopId;

    // Tenta encontrar pelo mapeamento direto ou buscando na lista de lojas da GG.deals
    if (_storeNameToGGDShopId.containsKey(cheapSharkStoreName)) {
        ggdShopId = _storeNameToGGDShopId[cheapSharkStoreName];
    } else {
        // Busca na lista de lojas da GG.deals se o mapeamento direto falhar
        var foundShop = ggdShops.firstWhereOrNull((s) => s.title.toUpperCase() == cheapSharkStoreName);
        if (foundShop == null && cheapSharkStoreName.contains("STEAM")) { // Fallback comum para Steam
            foundShop = ggdShops.firstWhereOrNull((s) => s.id.toUpperCase() == "STEAM");
        }
        ggdShopId = foundShop?.id;
    }


    if (ggdShopId == null) {
      print("[DealDetailController] Não foi possível mapear a loja '${deal.value!.storeName}' para um ID da GG.deals.");
      deal.value!.updateWithGGDPrice(null);
      return;
    }
    print("[DealDetailController] ID da Loja GG.deals para ${deal.value!.storeName}: $ggdShopId");

    // 3. Obter código do país do usuário
    String countryCode = _prefsService.selectedCountryCode.value;

    // 4. Buscar preço regional
    final ggdPriceInfo = await _ggdApiProvider.getRegionalPriceForShop(
      plain: plain,
      countryCode: countryCode,
      shopId: ggdShopId,
    );

    deal.value!.updateWithGGDPrice(ggdPriceInfo); // Atualiza o DealModel
    if (ggdPriceInfo != null) {
      print("[DealDetailController] Preço regional obtido: ${ggdPriceInfo.priceFormatted}");
    } else {
      print("[DealDetailController] Preço regional não encontrado para ${deal.value!.title} na loja $ggdShopId / país $countryCode.");
    }
  }

  Future<void> _fetchAndApplyRegionalPrice() async {
    if (deal.value == null) {
      // Se deal for nulo, garante que isLoading seja false se foi setado
      // Isso não deveria acontecer se onInit setou deal.value corretamente
      print("[DealDetailController] _fetchAndApplyRegionalPrice: deal.value é nulo.");
      return;
    }

    // Não precisa mais setar isLoadingRegionalPrice.value = true aqui,
    // pois _initiateRegionalPriceFetch já fez isso.
    // Apenas garanta que ele seja setado para false no final.

    GGDShopPrice? ggdPriceInfo; // Para armazenar o resultado

    try {
      String? plain;
      if (deal.value!.steamAppID != null && deal.value!.steamAppID!.isNotEmpty) {
        plain = await _ggdApiProvider.getPlainForGame(steamAppId: deal.value!.steamAppID);
      }
      if (plain == null || plain.isEmpty) {
        plain = await _ggdApiProvider.getPlainForGame(title: deal.value!.title);
      }

      if (plain == null || plain.isEmpty) {
        print("[DealDetailController] Não foi possível encontrar o 'plain' para ${deal.value!.title}");
        deal.value!.updateWithGGDPrice(null); // Isso já define isLoading=false e fetched=true
        return;
      }
      print("[DealDetailController] Plain para ${deal.value!.title}: $plain");

      String? cheapSharkStoreName = deal.value!.storeName.toUpperCase();
      String? ggdShopId;
      
      var foundShop = ggdShops.firstWhereOrNull((s) => 
          s.title.toUpperCase() == cheapSharkStoreName || 
          s.id.toUpperCase() == cheapSharkStoreName ||
          (cheapSharkStoreName.contains("STEAM") && s.id.toUpperCase() == "STEAM") || // Mapeamento especial para Steam
          (cheapSharkStoreName.contains("GOG") && s.id.toUpperCase() == "GOG") // Mapeamento especial para GOG
          // Adicione mais mapeamentos diretos se necessário
      );
      ggdShopId = foundShop?.id;

      if (ggdShopId == null) {
        print("[DealDetailController] Não foi possível mapear a loja '${deal.value!.storeName}' para um ID da GG.deals.");
        deal.value!.updateWithGGDPrice(null);
        return;
      }
      print("[DealDetailController] ID da Loja GG.deals para ${deal.value!.storeName}: $ggdShopId");

      String countryCode = _prefsService.selectedCountryCode.value;
      ggdPriceInfo = await _ggdApiProvider.getRegionalPriceForShop(
        plain: plain,
        countryCode: countryCode,
        shopId: ggdShopId,
      );

      // A atualização do deal (incluindo isLoading e fetched) é feita aqui:
      deal.value!.updateWithGGDPrice(ggdPriceInfo); 

      if (ggdPriceInfo != null) {
        print("[DealDetailController] Preço regional obtido: ${ggdPriceInfo.priceFormatted}");
      } else {
        print("[DealDetailController] Preço regional não encontrado para ${deal.value!.title} na loja $ggdShopId / país $countryCode.");
      }

    } catch (e, stackTrace) {
      print("[DealDetailController] EXCEÇÃO em _fetchAndApplyRegionalPrice: $e");
      print(stackTrace);
      if (deal.value != null) {
        deal.value!.updateWithGGDPrice(null); // Garante que flags sejam resetadas em caso de erro
      }
    }
    // Não é necessário um finally se updateWithGGDPrice(ggdPriceInfo) sempre é chamado
    // e lida com isLoadingRegionalPrice.value = false.
    // A lógica atual com updateWithGGDPrice(null) nos retornos antecipados e no catch já cobre isso.
  }
}