import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/widgets/deals/deals_filter_widget.dart';
import 'package:loot_app/app/widgets/deals/list_item_deal_card_widget.dart';

class DealsListScreenContent extends GetView<DealsController> {
  const DealsListScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    print(
      "[DealsListScreenContent] build. Buscando (query principal): ${controller.searchQuery.value}",
    );
    return RefreshIndicator(
      onRefresh: controller.refreshDealsList,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.filter_list_alt),
              label: const Text("Filtrar e Ordenar Resultados"),
              onPressed: () => Get.bottomSheet(
                DealsFilterWidget(),
                isScrollControlled: true,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.dealsList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.dealsList.isEmpty) {
                return Center(/* ... Mensagem de "Nenhuma promoção"... */);
              }
              return ListView.builder(
                controller: controller.scrollController,
                itemCount:
                    controller.dealsList.length +
                    (controller.isLoadingMore.value ? 1 : 0) +
                    (!controller.canLoadMoreDeals.value &&
                            controller.dealsList.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index < controller.dealsList.length) {
                    final deal = controller.dealsList[index];
                    // VVVVVV USA O NOVO WIDGET AQUI VVVVVV
                    return ListItemDealCardWidget(deal: deal);
                  } else if (index == controller.dealsList.length &&
                      controller.isLoadingMore.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (index == controller.dealsList.length &&
                      !controller.canLoadMoreDeals.value &&
                      controller.dealsList.isNotEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Fim das promoções."),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
