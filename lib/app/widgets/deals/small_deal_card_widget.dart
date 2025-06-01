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

    // Preparar URL da imagem com proxy
    String proxiedImageUrl = '';
    if (deal.thumb.isNotEmpty) {
      String encodedImageUrl = Uri.encodeComponent(deal.thumb);
      proxiedImageUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl";
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8), // Ajustando margem para consistência
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Menos arredondamento
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Log para verificar o objeto 'deal' ANTES de navegar
          print("[CardWidget] Navegando para detalhes: ${deal.title}");

          Get.toNamed(AppRoutes.DEAL_DETAIL, arguments: deal);
        },
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibindo o nome da loja
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  deal.storeName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Imagem da promoção
              Container(
                height: 90, // Aumentando a altura da imagem para maior destaque
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: proxiedImageUrl.isNotEmpty
                    ? Image.network(
                        proxiedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
              ),
              // Detalhes da promoção
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título da promoção
                    Text(
                      deal.title,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600, // Leveza no peso da fonte
                        fontSize:
                            14, // Ajuste de tamanho para melhor legibilidade
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Preço da promoção com conversão de moeda
                        Obx(() {
                          if (!currencyService.ratesInitialized.value &&
                              currencyService.isLoadingRates.value) {
                            return const SizedBox(
                              height: 16,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            );
                          }
                          String displaySalePrice = currencyService
                              .getFormattedPrice(deal.salePriceValue);
                          return Text(
                            displaySalePrice,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                        // Desconto percentual, se houver
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
            ],
          ),
        ),
      ),
    );
  }
}
