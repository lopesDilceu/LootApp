// lib/app/data/providers/deals_api_provider.dart
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/data/models/store_model.dart';

class DealsApiProvider extends GetConnect {
  final String _cheapSharkBaseUrl = "https://www.cheapshark.com/api/1.0";

  @override
  void onInit() {
    httpClient.baseUrl = _cheapSharkBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    // Não é necessária chave de API para o endpoint /deals do CheapShark
  }

    Future<List<StoreModel>> getStores() async {
    print("[DealsApiProvider] Buscando lista de lojas...");
    try {
      final response = await get("/stores");
      if (response.statusCode == 200 && response.body != null && response.body is List) {
        final List<dynamic> storesJson = response.body;
        return storesJson
            .map((json) => StoreModel.fromJson(json as Map<String, dynamic>))
            .where((store) => store.isActive) // Opcional: filtrar apenas lojas ativas
            .toList();
      } else {
        print("[DealsApiProvider] Erro ao buscar lojas: ${response.statusCode} - ${response.statusText}");
        Get.snackbar("Erro API", "Falha ao carregar lista de lojas.", snackPosition: SnackPosition.BOTTOM);
        return [];
      }
    } catch (e) {
      print("[DealsApiProvider] Exceção ao buscar lojas: $e");
      Get.snackbar("Erro de Rede", "Não foi possível buscar lista de lojas.", snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }

  Future<List<DealModel>> getDeals({
    int pageNumber = 0,
    int pageSize = 30,
    String? sortBy, // Tornando opcional para usar o default da API ou o do controller
    bool onSale = true,
    String? title,
    List<String>? storeIDs, // Lista de IDs de lojas para filtrar
    String? lowerPrice,     // Preço mínimo
    String? upperPrice,     // Preço máximo
    String? metacritic,     // Score mínimo do Metacritic
    // Adicione outros parâmetros de filtro da API do CheapShark conforme necessário
  }) async {
    final Map<String, String> queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'onSale': onSale ? '1' : '0',
    };
    if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
    if (title != null && title.trim().isNotEmpty) queryParams['title'] = title.trim();
    if (storeIDs != null && storeIDs.isNotEmpty) queryParams['storeID'] = storeIDs.join(','); // API espera IDs separados por vírgula
    if (lowerPrice != null && lowerPrice.isNotEmpty) queryParams['lowerPrice'] = lowerPrice;
    if (upperPrice != null && upperPrice.isNotEmpty) queryParams['upperPrice'] = upperPrice;
    if (metacritic != null && metacritic.isNotEmpty) queryParams['metacritic'] = metacritic;

    print("[DealsApiProvider] Buscando promoções com params: $queryParams");
    // ... o resto do método (try-catch, chamada API, parsing) continua igual ...
    // Lembre-se de tratar a resposta e erros como já estava fazendo.
    try {
      final response = await get("/deals", query: queryParams);
      if (response.statusCode == 200) { // ... (lógica de parsing como antes)
        if (response.body != null && response.body is List) {
          final List<dynamic> dealsJson = response.body;
          return dealsJson.map((json) => DealModel.fromJson(json as Map<String, dynamic>)).toList();
        } else { return []; }
      } else { 
        Get.snackbar("Erro API (${response.statusCode})", "Falha ao carregar promoções.", snackPosition: SnackPosition.BOTTOM);
        return []; 
      }
    } catch (e) {
      Get.snackbar("Erro de Rede", "Não foi possível buscar promoções.", snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }

  // Futuramente, você pode adicionar um método para buscar informações das lojas:
  // Future<List<StoreInfoModel>> getStoresInfo() async { ... httpClient.get("/stores") ... }
}