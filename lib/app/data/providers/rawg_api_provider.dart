// Exemplo em um novo RawgApiProvider.dart
import 'package:get/get.dart';
import 'dart:convert';

class RawgApiProvider extends GetConnect {
  final String _baseUrl = "https://api.rawg.io/api";
  final String _apiKey =
      "f993c9ed681743a6b0e4368d82a55949"; // Guarde de forma segura

  @override
  void onInit() {
    httpClient.baseUrl = _baseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultDecoder = (map) {
      if (map is Map<String, dynamic>) return map;
      if (map is List) return map.cast<Map<String, dynamic>>();
      if (map is String) return jsonDecode(map);
      return map;
    };
    // RAWG não precisa de token de autorização no header, apenas a key na query.
    super.onInit();
  }

  // Busca screenshots de um jogo pelo ID da RAWG
  Future<List<String>> getGameScreenshots(int rawgGameId) async {
    final String endpoint = "/games/$rawgGameId/screenshots";
    List<String> imageUrls = [];
    try {
      final response = await get(
        endpoint,
        query: {'key': _apiKey},
      ); //httpClient.get
      if (response.isOk && response.body['results'] != null) {
        final List<dynamic> results = response.body['results'];
        for (var screenshotData in results) {
          if (screenshotData['image'] != null) {
            imageUrls.add(screenshotData['image'] as String);
          }
        }
      } else {
        print(
          "[RawgApiProvider] Erro ao buscar screenshots RAWG: ${response.statusCode} - ${response.statusText}",
        );
      }
    } catch (e) {
      print("[RawgApiProvider] Exceção ao buscar screenshots RAWG: $e");
    }
    return imageUrls;
  }

  // Busca um jogo (para obter o ID da RAWG) pelo steamAppID ou título
  Future<int?> findRawgGameId({String? steamAppId, String? title}) async {
    Map<String, String> queryParams = {'key': _apiKey};
    if (steamAppId != null && steamAppId.isNotEmpty) {
      // A RAWG pode não ter um endpoint direto para buscar por steamAppID.
      // Uma estratégia é buscar pelo título e depois filtrar pelos external_ids.
      // OU buscar pelo título e assumir o primeiro resultado se o título for preciso.
      // Exemplo buscando por título (precisa de mais tratamento para correspondência exata):
      if (title != null && title.isNotEmpty) queryParams['search'] = title;
    } else if (title != null && title.isNotEmpty) {
      queryParams['search'] = title;
    } else {
      return null;
    }

    try {
      final response = await httpClient.get("/games", query: queryParams);
      if (response.isOk &&
          response.body['results'] != null &&
          (response.body['results'] as List).isNotEmpty) {
        final List<dynamic> games = response.body['results'];
        // Aqui você precisaria de uma lógica para encontrar o jogo correto.
        // Se buscou por steamAppId (indiretamente), precisaria iterar e checar 'stores' ou 'external_ids'.
        // Por simplicidade, se buscou por título, pegamos o primeiro.
        // PARA STEAM_APP_ID: você pode precisar iterar pelos 'stores' de cada jogo
        // ou usar um endpoint que aceite ID externo se a RAWG tiver (verifique a doc).
        for (var gameData in games) {
          if (steamAppId != null && gameData['stores'] != null) {
            for (var storeEntry in gameData['stores']) {
              if (storeEntry['store'] != null &&
                  storeEntry['store']['slug'] == 'steam' &&
                  gameData['id'] !=
                      null /* e comparar o ID da URL da loja com steamAppId */ ) {
                // Este é um exemplo complexo de como achar via steamAppId
                // Melhor se a API da RAWG tiver busca direta por external ID
              }
            }
          }
          // Por agora, se título foi usado na busca, apenas pegamos o primeiro ID
          if (gameData['id'] != null) {
            return gameData['id'] as int;
          }
        }
        return games[0]['id'] as int?;
      }
    } catch (e) {
      print("[RawgApiProvider] Exceção ao encontrar jogo na RAWG: $e");
    }
    return null;
  }

  Future<int?> findRawgGameIdByTitle(String title) async {
    // Este é um exemplo simples. A API da RAWG pode ter formas melhores de encontrar
    // ou você pode precisar de uma lógica mais robusta para correspondência de títulos.
    try {
      final response = await get(
        "/games",
        query: {'key': _apiKey, 'search': title, 'page_size': '1'},
      );
      if (response.isOk &&
          response.body['results'] != null &&
          (response.body['results'] as List).isNotEmpty) {
        return (response.body['results'][0]['id'] as int?);
      }
      print(
        "[RawgApiProvider] Jogo não encontrado na RAWG por título '${title}': ${response.statusCode}",
      );
    } catch (e) {
      print(
        "[RawgApiProvider] Exceção ao encontrar jogo na RAWG por título: $e",
      );
    }
    return null;
  }

  Future<int?> findRawgGameIdBySteamId(String steamAppId) async {
    // A API da RAWG permite buscar detalhes de um jogo e ver seus IDs externos.
    // Uma abordagem mais direta seria se eles tivessem um endpoint /games?steam_id=xxx
    // Se não, você pode precisar buscar por título (se o steamAppId estiver associado ao jogo da CheapShark)
    // e depois verificar o external_id ou store link da Steam nos resultados.
    // Este é um placeholder e precisaria de uma lógica mais robusta ou endpoint específico.
    print(
      "[RawgApiProvider] findRawgGameIdBySteamId não implementado de forma otimizada. Usando título do deal como fallback se disponível.",
    );
    return null; // Implemente uma lógica real aqui se possível
  }
}
