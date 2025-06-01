import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/routes/app_routes.dart';
// import 'package:loot_app/app/services/currency_service.dart'; // Para navegação para detalhes

class SmallDealCardWidget extends StatelessWidget {
  final DealModel deal;

  const SmallDealCardWidget({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {

    String proxiedImageUrl = '';
    if (deal.thumb.isNotEmpty) {
      String encodedImageUrl = Uri.encodeComponent(deal.thumb);
      // Obtém a URL base do proxy configurada globalmente
      proxiedImageUrl = "${ApiConstants.imageProxyUrlPrefix}$encodedImageUrl";
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(6), // Margem menor
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

          Get.toNamed(
            AppRoutes.DEAL_DETAIL,
            arguments: deal, // Passa o objeto 'deal'
          );
        },
        child: SizedBox(
          width:
              160, // Largura fixa para consistência em listas horizontais/grids
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagem
              Container(
                height: 85,
                width: double.infinity,
                color: Colors
                    .grey[200], // Cor de fundo para o placeholder da imagem
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
              // Detalhes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() { // Observa os campos Rx DENTRO do deal
                if (deal.isLoadingRegionalPrice.value) {
                  return const SizedBox(
                    width: 60, // Para manter o espaço do preço
                    child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }

                String displaySalePrice;
                // Prioriza o preço regional formatado se disponível e buscado
                if (deal.regionalPriceFetched.value && deal.regionalPriceFormatted.value != null) {
                  displaySalePrice = deal.regionalPriceFormatted.value!;
                } else {
                  // Fallback para o preço USD da CheapShark (sem conversão aqui, apenas exibição)
                  // A conversão com CurrencyService seria um fallback mais profundo se desejado.
                  displaySalePrice = "\$${deal.salePriceValue.toStringAsFixed(2)} (USD)";
                }

                // Você precisaria de uma lógica similar para deal.normalPrice se quiser exibi-lo
                // e se o GG.deals o fornecer (ex: através de deal.regionalNormalPriceFormatted)

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displaySalePrice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, // Ajustado para consistência
                        color: Colors.green[700],
                      ),
                      textAlign: TextAlign.right,
                    ),
                    // Se você tiver o preço normal regionalizado ou quiser mostrar o USD como antes:
                    // if (deal.normalPriceValue > 0 && deal.normalPriceValue > deal.salePriceValue)
                    //   Text(
                    //     /* Lógica para preço normal regionalizado ou fallback USD */
                    //     "\$${deal.normalPriceValue.toStringAsFixed(2)}",
                    //     style: TextStyle(decoration: TextDecoration.lineThrough, fontSize: 10, color: Colors.grey[600]),
                    //   ),
                    if (deal.savingsPercentage > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            "-${deal.savingsPercentage.toStringAsFixed(0)}%",
                            style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
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
            ],
          ),
        ),
      ),
    );
  }
}
