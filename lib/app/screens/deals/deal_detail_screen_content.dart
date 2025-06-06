import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';
import 'package:loot_app/app/services/currency_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:loot_app/app/widgets/common/app_bar.dart';

class DealDetailScreenContent extends GetView<DealDetailController> {
  const DealDetailScreenContent({super.key});

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
    final CurrencyService currencyService = CurrencyService.to;

    return Obx(() {
      final currentDeal = controller.deal.value;
      if (currentDeal == null) {
        return const Center(child: Text("Carregando detalhes..."));
      }

      // A imagem principal (controller.displayImageUrl) pode ser diferente do carrossel
      // ou ser a primeira imagem do carrossel. Aqui, está separada.
      final String mainProxiedImageUrl = controller.displayImageUrl;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem Principal (opcional, se quiser uma imagem de destaque antes do carrossel)
            // Se não quiser, pode remover este Container e ir direto para o carrossel.
            if (mainProxiedImageUrl.isNotEmpty &&
                controller.gameImageUrls.isEmpty &&
                !controller.isLoadingImages.value)
              Container(
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
                  child: Image.network(
                    mainProxiedImageUrl,
                    fit: BoxFit.contain /* errorBuilder, loadingBuilder */,
                  ),
                ),
              ),

            // Carrossel de Imagens da RAWG
            Obx(() {
              if (controller.isLoadingImages.value &&
                  controller.gameImageUrls.isEmpty) {
                // Mostra loader só se lista estiver vazia E carregando
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.gameImageUrls.isEmpty) {
                return Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              // Mostra o carrossel
              return Column(
                children: [
                  SizedBox(
                    height: 220, // Altura do carrossel
                    child: PageView.builder(
                      controller: controller.imageCarouselController,
                      itemCount: controller.gameImageUrls.length,
                      onPageChanged: (index) {
                        controller.currentImageIndex.value = index;
                      },
                      // itemBuilder: (context, index) {
                      //   String originalImageUrl =
                      //       controller.gameImageUrls[index];
                      //   String proxiedScreenshotUrl = '';
                      //   if (originalImageUrl.isNotEmpty) {
                      //     proxiedScreenshotUrl =
                      //         "${ApiConstants.imageProxyUrlPrefix}${Uri.encodeComponent(originalImageUrl)}";
                      //   }
                      //   return Padding(
                      //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      //     child: ClipRRect(
                      //       borderRadius: BorderRadius.circular(8.0),
                      //       child: proxiedScreenshotUrl.isNotEmpty
                      //           ? Image.network(
                      //               proxiedScreenshotUrl,
                      //               fit: BoxFit.contain,
                      //               errorBuilder: (c, e, s) => const Icon(
                      //                 Icons.broken_image,
                      //                 color: Colors.grey,
                      //               ),
                      //               loadingBuilder: (c, child, progress) =>
                      //                   progress == null
                      //                   ? child
                      //                   : const Center(
                      //                       child: CircularProgressIndicator(),
                      //                     ),
                      //             )
                      //           : const Icon(
                      //               Icons.image_not_supported,
                      //               color: Colors.grey,
                      //             ),
                      //     ),
                      //   );
                      // },
                      itemBuilder: (context, index) {
                        String originalImageUrlFromCarousel =
                            controller.gameImageUrls[index];

                        // VVVVVV ALTERAÇÃO PARA TESTE SEM PROXY VVVVVV
                        // String urlParaExibirNoCarrossel = "${ApiConstants.imageProxyUrlPrefix}${Uri.encodeComponent(originalImageUrlFromCarousel)}";
                        String urlParaExibirNoCarrossel =
                            originalImageUrlFromCarousel; // USA A URL ORIGINAL DIRETAMENTE
                        print(
                          "[DealDetailScreen_Carousel] Testando URL direta (sem proxy): $urlParaExibirNoCarrossel",
                        );
                        // ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: urlParaExibirNoCarrossel.isNotEmpty
                                ? Image.network(
                                    urlParaExibirNoCarrossel,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) {
                                      print(
                                        "[DealDetailScreen_Carousel] Erro ao carregar imagem DIRETA: $e - URL: $urlParaExibirNoCarrossel",
                                      );
                                      return const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 50,
                                      );
                                    },
                                    loadingBuilder: (c, child, progress) =>
                                        progress == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                  )
                                : const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 50,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (controller.gameImageUrls.length > 1) ...[
                    // Só mostra indicador se mais de 1 imagem
                    const SizedBox(height: 10),
                    SmoothPageIndicator(
                      controller: controller.imageCarouselController,
                      count: controller.gameImageUrls.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: Colors.grey.shade300,
                      ),
                      onDotClicked: (index) {
                        controller.imageCarouselController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                    ),
                  ],
                ],
              );
            }),

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
              currencyService.getFormattedPrice(currentDeal.salePriceValue),
              valueColor: Colors.green[700],
              isBold: true,
            ),
            _buildInfoRow(
              "Preço Normal",
              currencyService.getFormattedPrice(currentDeal.normalPriceValue),
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

            if (currentDeal.releaseDate != null && currentDeal.releaseDate! > 0)
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
          ],
        ),
      );
    });
  }
}
