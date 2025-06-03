import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/currency_service.dart';

class SmallDealCardWidget extends StatelessWidget {
  final DealModel deal;

  const SmallDealCardWidget({super.key, required this.deal});

  @override
Widget build(BuildContext context) {
  final CurrencyService currencyService = CurrencyService.to;

  String proxiedImageUrl = '';
  if (deal.thumb.isNotEmpty) {
    String encodedImageUrl = Uri.encodeComponent(deal.thumb);
    proxiedImageUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl";
    
  }

  final double screenWidth = MediaQuery.of(context).size.width;
  final double cardWidth = screenWidth * 0.9; // 80% da largura da tela
  final double cardHeight = 180; // altura fixa para evitar overflow

  return Card(
    elevation: 0,
    margin: const EdgeInsets.all(3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () {
        print("[CardWidget] Navegando para detalhes: ${deal.title}");
        Get.toNamed(AppRoutes.DEAL_DETAIL, arguments: deal);
      },
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Stack(
          children: [
            // Imagem de fundo ocupando todo o card
            Positioned.fill(
              child: proxiedImageUrl.isNotEmpty
                  ? Image.network(
                      proxiedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
            ),

            // Gradiente e texto - faixa superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  deal.storeName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Gradiente e texto - faixa inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deal.title,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          if (!currencyService.ratesInitialized.value &&
                              currencyService.isLoadingRates.value) {
                            return const SizedBox(
                              height: 16,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                          String displaySalePrice =
                              currencyService.getFormattedPrice(deal.salePriceValue);
                          return Text(
                            displaySalePrice,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                        if (deal.savingsPercentage > 0)
                          Text(
                            "-${deal.savingsPercentage.toStringAsFixed(0)}%",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
