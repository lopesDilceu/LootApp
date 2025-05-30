import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';
// Importe um widget para exibir o card da promoção, se tiver um.
// Ex: import 'package:loot_app/app/widgets/deals/deal_card_widget.dart';
import 'package:loot_app/app/data/models/deal_model.dart'; // Para usar DealModel no itemBuilder

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  Widget _buildDealCard(DealModel deal) { // Widget de card de promoção simples
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Implementar navegação para detalhes da promoção ou abrir link externo
          print("Promoção tocada: ${deal.title}");
          // Exemplo: Get.toNamed(AppRoutes.DEAL_DETAIL, arguments: deal.dealID);
          // ou usar url_launcher para abrir o link da promoção
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Image.network(
                deal.thumb,
                width: 100,
                height: 50, // Ajuste conforme a proporção da imagem do CheapShark
                fit: BoxFit.contain, // Ou BoxFit.cover
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 50),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text("Loja: ${deal.storeName}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text(
                      "Economia: ${deal.savingsPercentage.toStringAsFixed(0)}%",
                      style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "\$${deal.salePrice}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("[HomeScreen] build chamado. Usuário Logado: ${controller.authService.isLoggedIn}");
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Loot - Ofertas', // Título para a home pública
        // showBackButton: false, // O logo agora é o botão de home
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshHomepageDeals, // Para puxar e atualizar
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(() => Text(
                    controller.authService.isLoggedIn
                        ? 'Olá, ${controller.authService.currentUser.value?.firstName ?? 'Jogador(a)'}! Confira as novidades:'
                        : '🔥 Promoções em Destaque',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  )),
              const SizedBox(height: 20),

              // Seção de Promoções em Destaque
              Obx(() {
                if (controller.isLoadingDeals.value && controller.topDeals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.topDeals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Text("Nenhuma promoção em destaque no momento. Tente atualizar!"),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topDeals.length,
                  itemBuilder: (context, index) {
                    final deal = controller.topDeals[index];
                    return _buildDealCard(deal); // Usando o widget de card
                  },
                );
              }),
              const SizedBox(height: 40),

              // Botão de Ação (Login/Cadastro ou Ver Todas as Promoções)
              Obx(() {
                if (controller.authService.isLoggedIn) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: controller.navigateToDealsList,
                    child: const Text('Ver Todas as Promoções'),
                  );
                } else {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: controller.navigateToLogin,
                    child: const Text('Acessar / Cadastrar para Mais'),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}