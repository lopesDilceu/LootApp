class GGDShopPrice {
  final String? shopName;
  final String? shopIdGGD; // ID da loja na GG.deals
  final String? priceFormatted;
  final double? priceNew;
  final double? priceOld;
  final String? currencySymbol; // GG.deals retorna 'currency'
  final String? currencyCode;   // GG.deals retorna 'currency_raw'
  final String? dealUrl;        // GG.deals retorna 'url'

  GGDShopPrice({
    this.shopName, this.shopIdGGD, this.priceFormatted, this.priceNew, this.priceOld,
    this.currencySymbol, this.currencyCode, this.dealUrl,
  });

  factory GGDShopPrice.fromJson(Map<String, dynamic> json) {
    return GGDShopPrice(
      shopName: json['shop']?['name'] as String?,
      shopIdGGD: json['shop']?['id'] as String?, // ex: 'steam', 'gog'
      priceFormatted: json['price_formatted'] as String?,
      priceNew: (json['price_new'] as num?)?.toDouble(),
      priceOld: (json['price_old'] as num?)?.toDouble(),
      currencySymbol: json['currency'] as String?, // Ajustado para 'currency'
      currencyCode: json['currency_raw'] as String?, // Ajustado para 'currency_raw'
      dealUrl: json['url'] as String?,
    );
  }
}

class GGDShopInfo { // Para /v1/shops/list
  final String id; // ex: "steam", "gog"
  final String title; // ex: "Steam", "GOG"
  GGDShopInfo({required this.id, required this.title});
  factory GGDShopInfo.fromJson(Map<String, dynamic> json) {
    return GGDShopInfo(id: json['id'] as String? ?? '', title: json['title'] as String? ?? '');
  }
}