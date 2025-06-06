import 'dart:convert';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/ggd_models.dart';

class GGDotDealsApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = ApiConstants.baseUrl; // <<< APONTA PARA O SEU BACKEND
    httpClient.timeout = const Duration(
      seconds: 25,
    ); // Timeout um pouco maior para chamadas de proxy
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return map;
      if (map is List) return map.cast<Map<String, dynamic>>();
      if (map is String) {
        try {
          return jsonDecode(map);
        } catch (e) {
          return map; /* Retorna a string se não for JSON válido */
        }
      }
      return map;
    };
    // NENHUM addRequestModifier para Authorization aqui, pois seu backend lida com a chave da GG.deals.
    super.onInit();
  }

  Future<List<GGDShopInfo>> getShops() async {
    final String endpoint =
        "api/ggd/shops"; // <<< ENDPOINT DO SEU BACKEND PROXY
    try {
      print("[GGDotDealsApiProvider] Chamando proxy de lojas: $endpoint");
      final response = await get(endpoint);
      if (response.isOk &&
          response.body != null &&
          response.body['list'] != null) {
        return (response.body['list'] as List)
            .map(
              (shopJson) =>
                  GGDShopInfo.fromJson(shopJson as Map<String, dynamic>),
            )
            .toList();
      }
      print(
        "[GGDotDealsApiProvider] Erro ao buscar lojas (via proxy): ${response.statusCode} - ${response.bodyString}",
      );
    } catch (e) {
      print("[GGDotDealsApiProvider] Exceção ao buscar lojas (via proxy): $e");
    }
    return [];
  }

  Future<String?> getPlainForGame({String? steamAppId, String? title}) async {
    final String endpoint =
        "api/ggd/plain"; // <<< ENDPOINT DO SEU BACKEND PROXY
    Map<String, String> queryParams = {};
    // Seu backend proxy repassará esses parâmetros para a GG.deals
    if (steamAppId != null && steamAppId.isNotEmpty)
      queryParams['steam_id'] = steamAppId;
    if (title != null && title.isNotEmpty) queryParams['title'] = title;
    if (queryParams.isEmpty) return null;

    print(
      "[GGDotDealsApiProvider] Chamando proxy de plain: $endpoint com params: $queryParams",
    );
    try {
      final response = await get(endpoint, query: queryParams);
      if (response.isOk &&
          response.body?['list'] != null &&
          (response.body['list'] as List).isNotEmpty) {
        return (response.body['list'][0]['plain'] as String?)?.trim();
      } else {
        print(
          "[GGDotDealsApiProvider] Erro/Vazio ao buscar plain (via proxy): ${response.statusCode} - ${response.bodyString}",
        );
      }
    } catch (e) {
      print("[GGDotDealsApiProvider] Exceção ao buscar plain (via proxy): $e");
    }
    return null;
  }

  Future<GGDShopPrice?> getRegionalPriceForShop({
    required String plain,
    required String countryCode,
    required String shopId, // ID da loja da GG.deals
  }) async {
    final String endpoint =
        "api/ggd/prices"; // <<< ENDPOINT DO SEU BACKEND PROXY
    Map<String, String> queryParams = {
      'plains': plain,
      'country': countryCode.toLowerCase(),
      'shops': shopId,
    };
    print(
      "[GGDotDealsApiProvider] Chamando proxy de preço regional: $endpoint com params: $queryParams",
    );
    try {
      final response = await get(endpoint, query: queryParams);
      if (response.isOk &&
          response.body != null &&
          response.body['list'] != null &&
          response.body['list'][plain] != null &&
          response.body['list'][plain]['list'] != null &&
          (response.body['list'][plain]['list'] as List).isNotEmpty) {
        return GGDShopPrice.fromJson(
          response.body['list'][plain]['list'][0] as Map<String, dynamic>,
        );
      } else {
        print(
          "[GGDotDealsApiProvider] Erro/Vazio ao buscar preço regional (via proxy): ${response.statusCode} - ${response.bodyString}",
        );
      }
    } catch (e) {
      print(
        "[GGDotDealsApiProvider] Exceção ao buscar preço regional (via proxy): $e",
      );
    }
    return null;
  }
}
