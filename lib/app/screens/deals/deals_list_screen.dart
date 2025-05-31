import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';
// Remova a importação do DealModel daqui se ListItemDealCardWidget não precisar dela no construtor
// import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/widgets/deals/deals_filter_widget.dart';
// Importe o novo widget de card de lista
import 'package:loot_app/app/widgets/deals/list_item_deal_card_widget.dart';

class DealsListScreen extends GetView<DealsController> {
  const DealsListScreen({super.key});

  // O método _buildDealCard que estava aqui agora é substituído pelo ListItemDealCardWidget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        // Usando o CommonAppBar como antes
        title: 'Promoções de Jogos',
        customActions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt),
            tooltip: "Filtrar Promoções",
            onPressed: () {
              Get.bottomSheet(
                DealsFilterWidget(),
                isScrollControlled: true,
                ignoreSafeArea: false,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshDealsList,
        child: Column(
          children: [
            // Barra de Busca (como antes)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                // ... (TextField e botão de busca como antes) ...
                // Verifique se os métodos chamados aqui (controller.clearSearchAndFetchInitial, controller.searchGamesByTitle)
                // existem no seu DealsController com esses nomes exatos.
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchTEC,
                      decoration: InputDecoration(
                        hintText: "Ex: Batman, Call of Duty...",
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: Obx(
                          () => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: controller
                                      .clearSearchAndFetchInitial, // VERIFIQUE ESTE NOME
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      onSubmitted: (value) {
                        controller.searchGamesByTitle(
                          value,
                        ); // VERIFIQUE ESTE NOME
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text("Buscar"),
                    onPressed: () {
                      controller.searchGamesByTitle(
                        controller.searchTEC.text,
                      ); // VERIFIQUE ESTE NOME
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Lista de Promoções
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
      ),
    );
  }
}
