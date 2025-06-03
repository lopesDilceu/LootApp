import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/widgets/deals/deals_filter_widget.dart';
import 'package:loot_app/app/widgets/deals/list_item_deal_card_widget.dart';

class DealsListScreenContent extends GetView<DealsController> {
  const DealsListScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    print("[DealsListScreenContent] build. Buscando (query principal): ${controller.searchQuery.value}");
    return RefreshIndicator(
      onRefresh: controller.refreshDealsList,
      child: Column(
        children: [
          // Barra de Busca NO CORPO DA TELA
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchTEC, // Usa o searchTEC do DealsController
                    decoration: InputDecoration(
                      hintText: "Ex: Batman, Call of Duty...",
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: Obx(() => 
                      controller.searchQuery.value.isNotEmpty // <<< OBSERVA A VARIÁVEL RxString searchQuery
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: controller.clearSearchInScreenAndFetchInitial,
                            )
                          : const SizedBox.shrink()),
                    ),
                    onSubmitted: (value) {
                      controller.searchGamesByTitleInScreen(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Buscar"),
                  onPressed: () {
                    controller.searchGamesByTitleInScreen(controller.searchTEC.text);
                    FocusScope.of(context).unfocus(); 
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12)),
                )
              ],
            ),
          ),
          // Botão de Filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.filter_list_alt),
              label: const Text("Filtrar e Ordenar Resultados"),
              onPressed: () => Get.bottomSheet(DealsFilterWidget(), isScrollControlled: true),
            ),
          ),
          Expanded(
            child: Obx(() {
                if (controller.isLoading.value &&
                    controller.dealsList.isEmpty) {
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