import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/services/currency_service.dart';

class ListItemDealCardWidget extends StatelessWidget {
  final DealModel deal;

  const ListItemDealCardWidget({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {

    String imageUrlToUse = deal.thumb; // Fallback para a thumbnail
    if (deal.steamAppID != null && deal.steamAppID!.isNotEmpty) {
      imageUrlToUse = 'https://steamcdn-a.akamaihd.net/steam/apps/${deal.steamAppID}/header.jpg';
      print("[SmallDealCard] Usando URL da Steam (header.jpg): $imageUrlToUse");
    } else {
      print("[SmallDealCard] Sem steamAppID, usando thumbnail: $imageUrlToUse");
    }

    String proxiedImageUrl = '';
    if (deal.thumb.isNotEmpty) {
      String encodedImageUrl = Uri.encodeComponent(imageUrlToUse);
      proxiedImageUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Log para verificar o objeto 'deal' ANTES de navegar
          print(
            "[CardWidget] Iniciando navegação para detalhes da promoção: ${deal.title}",
          );
          print(
            "[CardWidget] Tipo do objeto 'deal' sendo passado: ${deal.runtimeType}",
          );
          // Para ver os dados, você pode logar o JSON (se tiver o método toJson no DealModel)
          // print("[CardWidget] Dados do 'deal' (JSON): ${deal.toJson()}");
          // Ou alguns campos específicos:
          print(
            "[CardWidget] Deal ID: ${deal.dealID}, Deal Thumb: ${deal.thumb}",
          );

          MainNavigationController.to.navigateToDealDetailPage(deal);
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 110,
                height: 65,
                color: Colors.grey[200],
                child: proxiedImageUrl.isNotEmpty
                    ? Image.network(
                        proxiedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          ),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Deal Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: Get.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Loja: ${deal.storeName}",
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    if (deal.steamRatingText != null &&
                        deal.steamRatingText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          "Steam: ${deal.steamRatingText} (${deal.steamRatingPercent ?? ''}%)",
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Price Info
              Obx(() {
                // Obx para reagir a mudanças de moeda (via UserPreferencesService)
                // e disponibilidade de taxas (via CurrencyService)

                // O Obx precisa "ouvir" as variáveis reativas que afetam o resultado de getFormattedPrice.
                // Para garantir isso, podemos acessar as dependências dentro do Obx.
                // Embora o GetX seja bom em rastrear, ser explícito não prejudica.
                // UserPreferencesService.to.selectedCurrency.value; // Garante que o Obx ouça a moeda
                // currencyService.ratesInitialized.value; // Garante que o Obx ouça o estado das taxas
                // currencyService.exchangeRatesFromUSD; // Garante que o Obx ouça as taxas em si
                // No entanto, o GetX geralmente é inteligente o suficiente se getFormattedPrice
                // internamente acessa essas variáveis Rx.

                if (deal.isLoadingRegionalPrice.value) {
                  return const SizedBox(width: 60, child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))));
                }

                String displaySalePrice;
                String displayNormalPrice = ""; // Inicializa como vazia
                Color salePriceColor = Colors.grey[700]!; // Cor de fallback

                if (deal.regionalPriceFetched.value && deal.regionalPriceFormatted.value != null) {
                  displaySalePrice = deal.regionalPriceFormatted.value!;
                  salePriceColor = Colors.green[700]!; 
                  // Usa o preço normal regionalizado se disponível
                  if (deal.regionalNormalPriceFormatted.value != null && deal.regionalNormalPriceFormatted.value!.isNotEmpty) {
                     displayNormalPrice = deal.regionalNormalPriceFormatted.value!;
                  } else if (deal.normalPriceValue > deal.salePriceValue) { 
                     // Fallback para preço normal USD se regional não veio da GGDeals
                     displayNormalPrice = "\$${deal.normalPriceValue.toStringAsFixed(2)}";
                  }
                } else {
                  // Fallback para preços USD da CheapShark se o regional não foi buscado ou falhou
                  displaySalePrice = "\$${deal.salePriceValue.toStringAsFixed(2)}";
                  if (deal.normalPriceValue > 0 && deal.normalPriceValue > deal.salePriceValue) {
                    displayNormalPrice = "\$${deal.normalPriceValue.toStringAsFixed(2)}";
                  }
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(displaySalePrice, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: salePriceColor)),
                    if (displayNormalPrice.isNotEmpty)
                      Text(displayNormalPrice, style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10, color: Colors.grey[600])),
                    if (deal.savingsPercentage > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(3)),
                          child: Text("-${deal.savingsPercentage.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
