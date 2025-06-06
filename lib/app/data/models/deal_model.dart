// lib/app/data/models/deal_model.dart
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/ggd_models.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';

class DealModel {
  final String title;
  final String dealID;
  final String storeID; // ID da loja (ex: '1' para Steam)
  final String gameID;
  final String salePrice;
  final String normalPrice;
  final String savings; // Percentual de economia (ex: "85.042521")
  final String? metacriticScore;
  final String? steamRatingText; // Ex: "Very Positive"
  final String? steamRatingPercent;
  final String? steamAppID;
  final int? releaseDate; // Timestamp Unix
  final String thumb; // URL da imagem thumbnail do jogo
  // Adicione mais campos conforme a necessidade e o que a API CheapShark retorna

    // Getters para converter preços da CheapShark para double
  double get salePriceValue => double.tryParse(salePrice.replaceAll(',', '.')) ?? 0.0;
  double get normalPriceValue => double.tryParse(normalPrice.replaceAll(',', '.')) ?? 0.0;
  double get savingsPercentage => double.tryParse(savings) ?? 0.0;

  // --- Campos Reativos para dados da GG.deals ---
  final RxnString regionalPriceFormatted = RxnString();     // Ex: "R$ 24,99"
  final RxnString regionalNormalPriceFormatted = RxnString(); // Ex: "R$ 49,99"
  final RxnString regionalCurrencySymbol = RxnString();     // Ex: "R$" (pode vir da GG.deals ou UserPrefs)
  final RxnString regionalShopName = RxnString();         // Nome da loja como retornado pela GG.deals
  final RxBool isLoadingRegionalPrice = false.obs;         // True enquanto busca preço da GG.deals
  final RxBool regionalPriceFetched = false.obs;          // True se a busca na GG.deals foi tentada

  DealModel({
    required this.title,
    required this.dealID,
    required this.storeID,
    required this.gameID,
    required this.salePrice,
    required this.normalPrice,
    required this.savings,
    this.metacriticScore,
    this.steamRatingText,
    this.steamRatingPercent,
    this.steamAppID,
    this.releaseDate,
    required this.thumb,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      title: json['title'] as String? ?? 'Título Indisponível',
      dealID: json['dealID'] as String? ?? '',
      storeID: json['storeID'] as String? ?? '',
      gameID: json['gameID'] as String? ?? '',
      salePrice: json['salePrice'] as String? ?? '0.00',
      normalPrice: json['normalPrice'] as String? ?? '0.00',
      savings: json['savings'] as String? ?? '0.00',
      metacriticScore: json['metacriticScore'] as String?,
      steamRatingText: json['steamRatingText'] as String?,
      steamRatingPercent: json['steamRatingPercent'] as String?,
      steamAppID: json['steamAppID'] as String?,
      releaseDate: json['releaseDate'] as int?,
      thumb: json['thumb'] as String? ?? '', // Garanta que thumb não seja nulo
    );
  }


  // Helper para obter o nome da loja (requer mapeamento ou chamada à API /stores)
  String get storeName {
    // Mapeamento básico de exemplo. Idealmente, buscaria da API /stores do CheapShark.
    switch (storeID) {
      case '1': return 'Steam';
      case '2': return 'GamersGate';
      case '3': return 'GreenManGaming';
      case '7': return 'GOG';
      case '8': return 'Origin'; // EA App
      case '11': return 'Humble Store';
      case '13': return 'Uplay'; // Ubisoft Connect
      case '25': return 'Epic Games Store';
      case '27': return 'Fanatical';
      case '28': return 'WinGameStore';
      case '29': return 'GameBillet';
      case '30': return 'Voidu';
      // Adicione mais conforme necessário
      default: return 'Loja ID: $storeID';
    }
  }

    // Método para atualizar este DealModel com os dados de preço regional da GG.deals
  void updateWithGGDPrice(GGDShopPrice? ggdPrice) {
    if (ggdPrice != null) {
      regionalPriceFormatted.value = ggdPrice.priceFormatted;
      regionalShopName.value = ggdPrice.shopName;
      
      // Tenta obter o símbolo da moeda da GG.deals; se não vier, usa o do UserPreferencesService
      regionalCurrencySymbol.value = ggdPrice.currencySymbol ?? (ggdPrice.currencyCode != null 
                                        ? UserPreferencesService.to.getCurrencySymbol(ggdPrice.currencyCode!) 
                                        : null);
      
      // Formata o preço normal/antigo da GG.deals
      if (ggdPrice.priceOld != null) {
        // Se a GG.deals já fornecer um 'price_old_formatted', use-o diretamente.
        // Senão, formate aqui:
        final symbol = regionalCurrencySymbol.value ?? (ggdPrice.currencyCode != null ? UserPreferencesService.to.getCurrencySymbol(ggdPrice.currencyCode!) : '\$');
        regionalNormalPriceFormatted.value = "$symbol${ggdPrice.priceOld!.toStringAsFixed(2)}";
      } else {
        regionalNormalPriceFormatted.value = null;
      }
      print("[DealModel] ${title}: Preço regional atualizado para ${regionalPriceFormatted.value}");
    } else {
      // Se ggdPrice for nulo (ex: falha na busca na API da GG.deals ou preço não encontrado)
      regionalPriceFormatted.value = null; 
      regionalNormalPriceFormatted.value = null;
      regionalCurrencySymbol.value = null;
      regionalShopName.value = null; // Mantém o nome da loja da CheapShark como fallback
      print("[DealModel] ${title}: Não foi possível obter preço regional da GG.deals.");
    }
    regionalPriceFetched.value = true; // Marca que a tentativa de busca foi concluída
    isLoadingRegionalPrice.value = false; // Terminou de carregar (com sucesso ou falha)
  }
}