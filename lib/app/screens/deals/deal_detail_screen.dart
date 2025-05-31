import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatar data
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart'; // Seu AppBar

class DealDetailScreen extends GetView<DealDetailController> {
  const DealDetailScreen({super.key});

  Widget _buildInfoRow(
    String label,
    String? value, {
    Color? valueColor,
    bool isBold = false,
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
      appBar: CommonAppBar(title: controller.deal.value?.title ?? "Detalhes"),
      body: Obx(() {
        // Obx para reagir caso o 'deal' seja carregado de forma assíncrona no futuro
        final deal = controller.deal.value;
        if (deal == null) {
          return const Center(child: Text("Promoção não encontrada."));
        }

        String imageUrlToDisplay = deal.thumb;

        if (deal.steamAppID != null && deal.steamAppID!.isNotEmpty) {
          // Tenta pegar uma imagem maior da Steam (ex: header.jpg)
          String potentialSteamHeaderUrl =
              'https://steamcdn-a.akamaihd.net/steam/apps/${deal.steamAppID}/header.jpg';
          // Ou para a imagem de capa vertical:
          // String potentialSteamLibraryUrl = 'https://steamcdn-a.akamaihd.net/steam/apps/${deal.steamAppID}/library_600x900.jpg';

          // Você pode definir uma preferência ou até tentar carregar a maior e fazer fallback para a thumb se falhar.
          // Por simplicidade, vamos usar a headerUrl se steamAppID existir.
          imageUrlToDisplay = potentialSteamHeaderUrl;
          print(
            "[DealDetailScreen] Usando imagem da Steam: $imageUrlToDisplay",
          );
        }

        String proxiedImageUrl = '';
        if (deal.thumb.isNotEmpty) {
          String encodedImageUrl = Uri.encodeComponent(deal.thumb);
          proxiedImageUrl =
              "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl";
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem Maior
              Container(
                height: 180, // Altura maior para a imagem de detalhe
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: proxiedImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          proxiedImageUrl,
                          fit: BoxFit
                              .contain, // Ou BoxFit.cover dependendo da proporção
                          errorBuilder: (ctx, err, st) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 70,
                              color: Colors.grey,
                            ),
                          ),
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 70,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              Text(
                deal.title,
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildInfoRow("Loja", deal.storeName),
              _buildInfoRow(
                "Preço em Promoção",
                "\$${deal.salePrice}",
                valueColor: Colors.green[700],
                isBold: true,
              ),
              _buildInfoRow(
                "Preço Normal",
                "\$${deal.normalPrice}",
                valueColor: Colors.grey[700],
              ),
              _buildInfoRow(
                "Você Economiza",
                "${deal.savingsPercentage.toStringAsFixed(0)}%",
                valueColor: Colors.redAccent,
                isBold: true,
              ),

              const Divider(height: 30),

              if (deal.metacriticScore != null &&
                  deal.metacriticScore!.isNotEmpty &&
                  deal.metacriticScore != "0")
                _buildInfoRow("Nota Metacritic", deal.metacriticScore!),

              if (deal.steamRatingText != null &&
                  deal.steamRatingText!.isNotEmpty)
                _buildInfoRow(
                  "Avaliação Steam",
                  "${deal.steamRatingText} (${deal.steamRatingPercent ?? ''}%)",
                ),

              if (deal.releaseDate != null && deal.releaseDate! > 0)
                _buildInfoRow(
                  "Lançamento",
                  DateFormat('dd/MM/yyyy', Get.locale?.toString()).format(
                    DateTime.fromMillisecondsSinceEpoch(
                      deal.releaseDate! * 1000,
                    ),
                  ),
                ),

              if (deal.steamAppID != null && deal.steamAppID!.isNotEmpty)
                _buildInfoRow("Steam App ID", deal.steamAppID!),

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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
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
