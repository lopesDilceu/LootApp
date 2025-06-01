import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';
// Importando o novo widget de card pequeno
import 'package:loot_app/app/widgets/deals/small_deal_card_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("[HomeScreen] build chamado. Usuário Logado: ${controller.authService.isLoggedIn}");

    return Scaffold(
      appBar: const CommonAppBar(title: 'Loot - Ofertas'),
      body: RefreshIndicator(
        onRefresh: controller.refreshHomepageDeals,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título de boas-vindas com base no login
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
                if (controller.isLoadingDeals.value && controller.topDeals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.topDeals.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0),
                      child: Text(
                        "Nenhuma promoção em destaque no momento. Tente atualizar!",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 240, // Altura do carrossel ajustada para o novo design
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.topDeals.length,
                    itemBuilder: (context, index) {
                      final deal = controller.topDeals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SmallDealCardWidget(deal: deal),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 40),

              // Botão de Ação (Login/Cadastro ou Ver Todas as Promoções)
              Obx(() {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: controller.authService.isLoggedIn
                      ? controller.navigateToDealsList
                      : controller.navigateToLogin,
                  child: Text(
                    controller.authService.isLoggedIn
                        ? 'Ver Todas as Promoções'
                        : 'Acessar / Cadastrar para Mais',
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
