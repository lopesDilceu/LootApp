import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';
import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/widgets/deals/deals_filter_widget.dart'; // Para o tipo DealModel
// Importe seu DealCardWidget se o tiver criado
// import 'package:loot_app/app/widgets/deals/deal_card_widget.dart'; 

class DealsListScreen extends GetView<DealsController> {
  const DealsListScreen({super.key});

  // Widget para exibir cada card de promoção (exemplo)
  Widget _buildDealCard(BuildContext context, DealModel deal) {
    // Use seu DealCardWidget aqui se tiver um, ou mantenha este exemplo
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: Image.network(deal.thumb, width: 80, fit: BoxFit.contain, 
          errorBuilder: (ctx,err,st) => const Icon(Icons.broken_image, size: 40)),
        title: Text(deal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${deal.storeName} - Economia: ${deal.savingsPercentage.toStringAsFixed(0)}%"),
        trailing: Text("\$${deal.salePrice}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
        onTap: () { /* TODO: Abrir link da promoção ou detalhes */ },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Promoções de Jogos',
        customActions: [
          IconButton(
            icon: const Icon(Icons.filter_list_alt), // Ícone de filtro
            tooltip: "Filtrar Promoções",
            onPressed: () {
              Get.bottomSheet(
                DealsFilterWidget(), // << USA O NOVO WIDGET AQUI
                isScrollControlled: true, // Permite que o BottomSheet use mais da metade da tela
                ignoreSafeArea: false, // Respeita a safe area inferior
                // backgroundColor: Colors.transparent, // Opcional, se DealsFilterWidget já tem cor
              );
            },
          ),
          const SizedBox(width: 8), // Espaçamento para o menu de usuário na AppBar
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: controller.refreshDealsList,
        child: Column(
          children: [
            // Barra de Busca
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchTEC,
                      decoration: InputDecoration(
                        hintText: "Ex: Batman, Call of Duty...",
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        suffixIcon: Obx(() => // Botão para limpar busca
                          controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: controller.clearSearchAndFetchInitial,
                                )
                              : const SizedBox.shrink()),
                      ),
                      onSubmitted: (value) { // Busca ao pressionar Enter no teclado
                        controller.searchGamesByTitle(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.search),
                    label: const Text("Buscar"),
                    onPressed: () {
                      controller.searchGamesByTitle(controller.searchTEC.text);
                      FocusScope.of(context).unfocus(); // Esconde o teclado
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12)),
                  )
                ],
              ),
            ),
            // Lista de Promoções
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.dealsList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.dealsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        controller.isSearching.value
                            ? "Nenhuma promoção encontrada para '${controller.searchQuery.value}'."
                            : "Nenhuma promoção no momento. Tente atualizar!",
                        textAlign: TextAlign.center, style: Get.textTheme.titleMedium,
                      ),
                    ),
                  );
                }
                // ListView para exibir as promoções
                return ListView.builder(
                  controller: controller.scrollController, // Para paginação
                  itemCount: controller.dealsList.length + 
                             (controller.isLoadingMore.value ? 1 : 0) + 
                             (!controller.canLoadMoreDeals.value && controller.dealsList.isNotEmpty ? 1: 0),
                  itemBuilder: (context, index) {
                    if (index < controller.dealsList.length) {
                      final deal = controller.dealsList[index];
                      return _buildDealCard(context, deal); // Use seu DealCardWidget
                    } else if (index == controller.dealsList.length && controller.isLoadingMore.value) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                    } else if (index == controller.dealsList.length && !controller.canLoadMoreDeals.value && controller.dealsList.isNotEmpty) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Fim das promoções.")));
                    }
                    return const SizedBox.shrink(); // Não deve chegar aqui
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