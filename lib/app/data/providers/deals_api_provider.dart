// lib/app/data/providers/deals_api_provider.dart
import 'package:flutter/material.dart'; // Para Colors no Get.snackbar
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/deal_model.dart';

class DealsApiProvider extends GetConnect {
  final String _cheapSharkBaseUrl = "https://www.cheapshark.com/api/1.0";

  @override
  void onInit() {
    httpClient.baseUrl = _cheapSharkBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    // Não é necessária chave de API para o endpoint /deals do CheapShark
  }

  Future<List<DealModel>> getDeals({
    int pageNumber = 0,
    int pageSize = 30, // CheapShark permite até 60
    String sortBy = 'Deal Rating', // Opções: 'Title', 'Savings', 'Price', 'Metacritic', 'Release', 'Store', 'recent'
    bool onSale = true, // Por padrão, buscar apenas o que está em promoção
    String? storeID, // Para filtrar por loja específica (ex: "1" para Steam)
  }) async {
    final Map<String, String> queryParams = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'sortBy': sortBy,
      'onSale': onSale ? '1' : '0',
    };
    if (storeID != null && storeID.isNotEmpty) {
      queryParams['storeID'] = storeID;
    }

    print("[DealsApiProvider] Buscando promoções com params: $queryParams");

    try {
      final response = await get("/deals", query: queryParams);

      if (response.statusCode == 200) {
        if (response.body != null && response.body is List) {
          final List<dynamic> dealsJson = response.body;
          if (dealsJson.isEmpty && pageNumber > 0) {
            print("[DealsApiProvider] Nenhuma promoção encontrada para a página $pageNumber (pode ser o fim da lista).");
            return []; // Fim da paginação ou sem resultados
          }
          return dealsJson.map((json) => DealModel.fromJson(json as Map<String, dynamic>)).toList();
        } else {
          print("[DealsApiProvider] Resposta de promoções não é uma lista ou está nula. Body: ${response.bodyString}");
          return []; // Retorna lista vazia em caso de formato inesperado
        }
      } else {
        print("[DealsApiProvider] Erro ao buscar promoções: ${response.statusCode} - ${response.statusText}");
        print("[DealsApiProvider] Corpo da Resposta: ${response.bodyString}");
        // Poderia lançar uma exceção ou retornar lista vazia com snackbar
        Get.snackbar("Erro de API", "Falha ao carregar promoções (Status: ${response.statusCode})",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
        return [];
      }
    } catch (e) {
      print("[DealsApiProvider] Exceção ao buscar promoções: $e");
      Get.snackbar("Erro de Rede", "Não foi possível conectar ao servidor de promoções.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return [];
    }
  }

  // Futuramente, você pode adicionar um método para buscar informações das lojas:
  // Future<List<StoreInfoModel>> getStoresInfo() async { ... httpClient.get("/stores") ... }
}