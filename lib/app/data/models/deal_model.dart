// lib/app/data/models/deal_model.dart
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:loot_app/app/data/models/ggd_model.dart';
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

  // Novos campos para preço regional (opcionais)
  RxnString regionalPriceFormatted = RxnString(); // Torna reativo
  RxnString regionalCurrencySymbol = RxnString();
  RxnString regionalShopName = RxnString(); // Nome da loja segundo GG.deals
  RxBool isLoadingRegionalPrice = false.obs;
  RxBool regionalPriceFetched = false.obs; // Para saber se já tentamos buscar

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

  // Getters para facilitar o uso dos dados convertidos
  double get salePriceValue => double.tryParse(salePrice) ?? 0.0;
  double get normalPriceValue => double.tryParse(normalPrice) ?? 0.0;
  double get savingsPercentage => double.tryParse(savings) ?? 0.0;

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

  // Método para atualizar com dados da GG.deals
  void updateWithGGDPrice(GGDShopPrice? ggdPrice) { // GGDShopPrice é o modelo da GG.deals
    if (ggdPrice != null && ggdPrice.priceFormatted != null) {
      regionalPriceFormatted.value = ggdPrice.priceFormatted;
      regionalCurrencySymbol.value = ggdPrice.currencySymbol ?? UserPreferencesService.to.getCurrencySymbol(ggdPrice.currencyCode ?? UserPreferencesService.to.selectedCountryCode.value); // Adapte conforme necessário
      regionalShopName.value = ggdPrice.shopName;
    } else {
      regionalPriceFormatted.value = null; 
      regionalCurrencySymbol.value = null;
      regionalShopName.value = null;
    }
    regionalPriceFetched.value = true; // Tentativa de busca concluída
    isLoadingRegionalPrice.value = false;
  }
}