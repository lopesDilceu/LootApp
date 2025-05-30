import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart'; // Seu DealsController

class DealsFilterWidget extends StatelessWidget {
  // Acessa a instância do DealsController que já deve ter sido inicializada
  // pela DealsBinding na DealsListScreen.
  final DealsController controller = Get.find<DealsController>();

  DealsFilterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Define uma altura máxima para o BottomSheet, mas ele se ajustará ao conteúdo
      // devido ao SingleChildScrollView e MainAxisSize.min no Column.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85, // 85% da altura da tela
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), // Padding, sem o de baixo para o botão colar
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Cor de fundo baseada no tema
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Faz o Column se ajustar ao conteúdo verticalmente
        children: [
          // Alça e Título
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            "Filtrar e Ordenar",
            style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Conteúdo dos Filtros (em um Expanded para permitir scroll interno)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ordenação
                  Text("Ordenar por:", style: Get.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                        ),
                        value: controller.selectedSortBy.value,
                        items: controller.sortOptions.map((String sortBy) {
                          return DropdownMenuItem<String>(value: sortBy, child: Text(sortBy));
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) controller.selectedSortBy.value = newValue;
                        },
                      )),
                  const SizedBox(height: 20),

                  // Faixa de Preço
                  Text("Faixa de Preço (USD):", style: Get.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: controller.lowerPriceTEC,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                                labelText: "De \$",
                                prefixText: "\$", // Adicionado prefixo
                                border: OutlineInputBorder()))),
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("-", style: TextStyle(fontSize: 18))),
                    Expanded(
                        child: TextField(
                            controller: controller.upperPriceTEC,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                                labelText: "Até \$",
                                prefixText: "\$", // Adicionado prefixo
                                border: OutlineInputBorder()))),
                  ]),
                  const SizedBox(height: 20),

                  // Lojas (Multi-seleção)
                  Text("Lojas:", style: Get.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Obx(() {
                    if (controller.availableStores.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Text("Carregando lojas...", style: TextStyle(fontStyle: FontStyle.italic)),
                      );
                    }
                    return Container(
                      constraints: BoxConstraints(maxHeight: Get.height * 0.25), // Limita altura
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.availableStores.length,
                        itemBuilder: (ctx, index) {
                          final store = controller.availableStores[index];
                          return Obx(() => CheckboxListTile(
                                title: Text(store.storeName, style: const TextStyle(fontSize: 14)),
                                value: controller.selectedStoreIDs.contains(store.storeID),
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                                onChanged: (bool? selected) {
                                  if (selected == true) {
                                    if (!controller.selectedStoreIDs.contains(store.storeID)) {
                                      controller.selectedStoreIDs.add(store.storeID);
                                    }
                                  } else {
                                    controller.selectedStoreIDs.remove(store.storeID);
                                  }
                                },
                              ));
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Botões de Ação (fora do SingleChildScrollView para ficarem fixos embaixo)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0), // Ajuste o padding se necessário
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.clear_all_rounded),
                  label: const Text("Limpar"),
                  onPressed: () {
                    controller.clearAllFilters();
                    // Get.back(); // Opcional: fechar após limpar, ou deixar aberto para nova aplicação
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text("Aplicar Filtros"),
                  onPressed: () {
                    controller.applyFilters();
                    Get.back(); // Fecha o BottomSheet após aplicar
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}