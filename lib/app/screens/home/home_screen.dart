import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';
// Importe o novo widget de card pequeno
import 'package:loot_app/app/widgets/deals/small_deal_card_widget.dart';
// DealModel ainda é necessário se você não passar para o SmallDealCardWidget diretamente do controller.topDeals
// import 'package:loot_app/app/data/models/deal_model.dart';
import 'package:loot_app/app/routes/app_routes.dart'; // Para navegação

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  // O método _buildDealCard que estava aqui agora é substituído pelo SmallDealCardWidget

  @override
  Widget build(BuildContext context) {
    print(
      "[HomeScreen] build chamado. Usuário Logado: ${controller.authService.isLoggedIn}",
    );
    return Scaffold(
      appBar: const CommonAppBar(title: 'Loot - Ofertas'),
      body: RefreshIndicator(
        onRefresh: controller.refreshHomepageDeals,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => Text(
                  controller.authService.isLoggedIn
                      ? 'Olá, ${controller.authService.currentUser.value?.firstName ?? 'Jogador(a)'}! Confira as novidades:'
                      : '🔥 Promoções em Destaque',
                  textAlign: TextAlign.center,
                  style: Get.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Seção de Promoções em Destaque
              Obx(() {
                if (controller.isLoadingDeals.value &&
                    controller.topDeals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.topDeals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Text(
                        "Nenhuma promoção em destaque no momento. Tente atualizar!",
                      ),
                    ),
                  );
                }
                // Você pode usar um ListView horizontal aqui se preferir
                // ou manter o ListView vertical. Para cards menores, um GridView também seria bom.
                // Exemplo com ListView vertical (como estava):
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.topDeals.length,
                  itemBuilder: (context, index) {
                    final deal = controller.topDeals[index];
                    // VVVVVV USA O NOVO WIDGET AQUI VVVVVV
                    return SmallDealCardWidget(deal: deal);
                  },
                );
                /* Exemplo com ListView horizontal:
                return SizedBox(
                  height: 190, // Ajuste a altura conforme o conteúdo do SmallDealCardWidget
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.topDeals.length,
                    itemBuilder: (context, index) {
                      final deal = controller.topDeals[index];
                      return SmallDealCardWidget(deal: deal);
                    },
                  ),
                );
                */
              }),
              const SizedBox(height: 40),

              // Botão de Ação (Login/Cadastro ou Ver Todas as Promoções)
              Obx(() {
                if (controller.authService.isLoggedIn) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: controller.navigateToDealsList,
                    child: const Text('Ver Todas as Promoções'),
                  );
                } else {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
