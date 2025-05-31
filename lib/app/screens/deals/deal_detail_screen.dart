import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';

class DealDetailScreen extends GetView<DealDetailController> {
  const DealDetailScreen({super.key});

  // ... (_buildInfoRow como antes) ...
  Widget _buildInfoRow(
    String label,
    String? value, {
    Color? valueColor,
    bool isBold = false,
    bool lineThrough = false,
  }) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Get.textTheme.titleSmall?.copyWith(
                color: valueColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                decoration: lineThrough
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: controller.deal.value?.title ?? "Detalhes da Promoção",
      ),
      body: Obx(() {
        final currentDeal = controller.deal.value;
        if (currentDeal == null) {
          return const Center(
            child: Text("Detalhes da promoção não disponíveis."),
          );
        }

        final String proxiedImageUrlToShow =
            controller.displayImageUrl; // Já usa o proxy
        print(
          "[DealDetailScreen] URL da imagem para exibir: $proxiedImageUrlToShow",
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                // Container da Imagem Principal
                height: 215,
                width: 460,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: proxiedImageUrlToShow.isNotEmpty
                      ? Image.network(
                          proxiedImageUrlToShow,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, st) {
                            print(
                              "[DealDetailScreen] Erro ao carregar imagem principal via proxy: $err - URL: $proxiedImageUrlToShow",
                            );
                            if (currentDeal.thumb.isNotEmpty) {
                              String encodedThumbUrl = Uri.encodeComponent(
                                currentDeal.thumb,
                              );
                              // VVVVVV USA A CONSTANTE AQUI VVVVVV
                              String proxiedThumbUrl =
                                  "${ApiConstants.imageProxyUrlPrefix}$encodedThumbUrl";
                              print(
                                "[DealDetailScreen] Fallback para thumbnail: $proxiedThumbUrl",
                              );
                              return Image.network(
                                proxiedThumbUrl,
                                height: 100,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image_outlined,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return const Icon(
                              Icons.broken_image_outlined,
                              size: 70,
                              color: Colors.grey,
                            );
                          },
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                ),
              ),
              // ... (resto da sua UI de detalhes como antes) ...
              const SizedBox(height: 20),
              Text(
                currentDeal.title,
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoRow("Loja", currentDeal.storeName),
              _buildInfoRow(
                "Preço em Promoção",
                "\$${currentDeal.salePrice}",
                valueColor: Colors.green[700],
                isBold: true,
              ),
              _buildInfoRow(
                "Preço Normal",
                "\$${currentDeal.normalPrice}",
                valueColor: Colors.grey[700],
              ),
              _buildInfoRow(
                "Você Economiza",
                "${currentDeal.savingsPercentage.toStringAsFixed(0)}% OFF",
                valueColor: Colors.redAccent,
                isBold: true,
              ),

              const Divider(height: 30),

              if (currentDeal.metacriticScore != null &&
                  currentDeal.metacriticScore!.isNotEmpty &&
                  currentDeal.metacriticScore != "0")
                _buildInfoRow("Nota Metacritic", currentDeal.metacriticScore!),

              if (currentDeal.steamRatingText != null &&
                  currentDeal.steamRatingText!.isNotEmpty)
                _buildInfoRow(
                  "Avaliação Steam",
                  "${currentDeal.steamRatingText} (${currentDeal.steamRatingPercent ?? ''}%)",
                ),

              if (currentDeal.releaseDate != null &&
                  currentDeal.releaseDate! > 0)
                _buildInfoRow(
                  "Lançamento",
                  DateFormat('dd/MM/yyyy', Get.locale?.toString()).format(
                    DateTime.fromMillisecondsSinceEpoch(
                      currentDeal.releaseDate! * 1000,
                    ),
                  ),
                ),

              if (currentDeal.steamAppID != null &&
                  currentDeal.steamAppID!.isNotEmpty)
                _buildInfoRow("Steam App ID", currentDeal.steamAppID!),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart_checkout_rounded),
                label: const Text("Ver Oferta na Loja"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: controller.launchDealUrl,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
