import 'dart:convert';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/ggd_model.dart'; // Seus modelos GG.deals

class GGDotDealsApiProvider extends GetConnect {
  final String _baseUrl = "https://api.gg.deals";
  // GUARDE SUA API KEY DE FORMA SEGURA! NÃO A COLOQUE DIRETAMENTE NO CÓDIGO.
  // Use variáveis de ambiente ou um arquivo de configuração ignorado pelo Git.
  final String _apiKey = '0ZT-B2NRmMsDPvB5Ykho_q9jKMjKUUe9';

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultDecoder = (map) { // Para facilitar o parse do JSON
      if (map is Map<String, dynamic>) return map;
      if (map is List) return map.cast<Map<String, dynamic>>(); // Se a API retornar uma lista
      if (map is String) return jsonDecode(map); // Se for string JSON
      return map;
    };
    // Adiciona o token de autorização a todas as requisições
    httpClient.addRequestModifier<void>((request) {
      request.headers['Authorization'] = 'Token $_apiKey';
      print("[GGDotDealsApiProvider] Requesting: ${request.url}");
      return request;
    });
  }

  Future<String?> getPlainForGame({String? steamAppId, String? title}) async {
    if (steamAppId == null && title == null) return null;

    Map<String, String> queryParams = {};
    if (steamAppId != null) queryParams['steam_id'] = steamAppId;
    if (title != null && steamAppId == null) queryParams['title'] = title; // Prefira steam_id se disponível

    try {
      final response = await get("/v1/games/plain", query: queryParams);
      if (response.isOk && response.body?['list'] != null && (response.body['list'] as List).isNotEmpty) {
        return (response.body['list'][0]['plain'] as String?)?.trim();
      } else {
        print("[GGDotDealsApiProvider] Erro ao buscar plain: ${response.statusCode} - ${response.bodyString}");
        return null;
      }
    } catch (e) {
      print("[GGDotDealsApiProvider] Exceção ao buscar plain: $e");
      return null;
    }
  }
  
  Future<List<GGDShopInfo>> getShops() async {
    try {
      final response = await get("/v1/shops/list");
      if (response.isOk && response.body['list'] != null) {
        return (response.body['list'] as List)
            .map((shopJson) => GGDShopInfo.fromJson(shopJson as Map<String, dynamic>))
            .toList();
      }
      print("[GGDotDealsApiProvider] Erro ao buscar lojas GG.deals: ${response.statusCode}");
      return [];
    } catch (e) {
      print("[GGDotDealsApiProvider] Exceção ao buscar lojas GG.deals: $e");
      return [];
    }
  }

  // Busca o preço regional para UM jogo em UMA loja específica
  Future<GGDShopPrice?> getRegionalPriceForShop({
    required String plain,
    required String countryCode, // ex: "BR"
    required String shopId,      // ID da loja no GG.deals (ex: "steam")
  }) async {
    final String endpoint = "/v2/prices";
    Map<String, String> queryParams = {
      'plains': plain,
      'country': countryCode.toUpperCase(),
      'shops': shopId,
    };
    try {
      final response = await get(endpoint, query: queryParams);
      if (response.isOk && response.body != null && response.body['list'] != null && response.body['list'][plain] != null) {
        final gamePriceData = response.body['list'][plain];
        if (gamePriceData['list'] != null && (gamePriceData['list'] as List).isNotEmpty) {
          // Retorna o primeiro preço encontrado para aquela loja/plain (geralmente só haverá um)
          return GGDShopPrice.fromJson(gamePriceData['list'][0] as Map<String, dynamic>);
        }
      } else {
        print("[GGDotDealsApiProvider] Erro ao buscar preço regional: ${response.statusCode} - ${response.bodyString}");
      }
    } catch (e) {
      print("[GGDotDealsApiProvider] Exceção ao buscar preço regional: $e");
    }
    return null;
  }
}