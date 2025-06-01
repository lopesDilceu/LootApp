// Modelo para a resposta de /v1/games/plain (simplificado)
class GGDPlainInfo {
  final String plain;
  final String title;

  GGDPlainInfo({required this.plain, required this.title});

  factory GGDPlainInfo.fromJson(Map<String, dynamic> json) {
    // A API retorna uma lista, pegamos o primeiro elemento se existir
    if (json['list'] != null && (json['list'] as List).isNotEmpty) {
      final firstMatch = json['list'][0];
      return GGDPlainInfo(
        plain: firstMatch['plain'] as String? ?? '',
        title: firstMatch['title'] as String? ?? '',
      );
    }
    // Fallback se a estrutura não for a esperada ou a lista estiver vazia
    return GGDPlainInfo(plain: '', title: json['title'] as String? ?? '');
  }
}

// Modelo para a informação de preço de uma loja específica na resposta de /v2/prices
class GGDShopPrice {
  final String? shopName;
  final String? shopId; // ID da loja no GG.deals (ex: "steam", "gog")
  final String? priceFormatted; // Ex: "R$ 24,99"
  final double? priceNew;       // Preço numérico atual
  final double? priceOld;       // Preço numérico antigo
  final String? currencySymbol; // Ex: "R$"
  final String? currencyCode;   // Ex: "BRL"
  final String? dealUrl;        // URL para a oferta na loja

  GGDShopPrice({
    this.shopName, this.shopId, this.priceFormatted, this.priceNew, this.priceOld,
    this.currencySymbol, this.currencyCode, this.dealUrl,
  });

  factory GGDShopPrice.fromJson(Map<String, dynamic> json) {
    return GGDShopPrice(
      shopName: json['shop']?['name'] as String?,
      shopId: json['shop']?['id'] as String?,
      priceFormatted: json['price_formatted'] as String?,
      priceNew: (json['price_new'] as num?)?.toDouble(),
      priceOld: (json['price_old'] as num?)?.toDouble(),
      currencySymbol: json['price_currency'] as String?, // Pode precisar de mapeamento se não for o símbolo
      currencyCode: json['price_currency_raw'] as String?, // Ex: "BRL"
      dealUrl: json['url'] as String?,
    );
  }
}

// Modelo para as lojas da GG.deals de /v1/shops/list
class GGDShopInfo {
  final String id; // ex: "steam", "gog", "nuuvem"
  final String title; // ex: "Steam", "GOG", "Nuuvem"

  GGDShopInfo({required this.id, required this.title});

  factory GGDShopInfo.fromJson(Map<String, dynamic> json) {
    return GGDShopInfo(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }
}