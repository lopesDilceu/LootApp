import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/constants/api/api_constants.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/routes/app_routes.dart'; // Para navegação para detalhes

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
          print("SmallDealCard Tapped: ${deal.title}");
          Get.toNamed(AppRoutes.DEAL_DETAIL, arguments: deal); // Navega para detalhes
        },
        child: SizedBox(
          width: 160, // Largura fixa para consistência em listas horizontais/grids
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagem
              Container(
                height: 85,
                width: double.infinity,
                color: Colors.grey[200], // Cor de fundo para o placeholder da imagem
                child: proxiedImageUrl.isNotEmpty
                    ? Image.network(
                        proxiedImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 30)),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
                        },
                      )
                    : const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30)),
              ),
              // Detalhes
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "\$${deal.salePrice}",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
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