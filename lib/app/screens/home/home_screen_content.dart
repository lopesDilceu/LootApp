import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/widgets/deals/small_deal_card_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importe o indicador

class HomeScreenContent extends GetView<HomeController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    print("[HomeScreenContent] build. Usuário Logado: ${controller.authService.isLoggedIn}");
    return RefreshIndicator(
      onRefresh: controller.refreshHomepageDeals,
      child: SingleChildScrollView(
        key: const PageStorageKey('homeScreenScroll'),
        padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding vertical apenas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding( // Padding para o texto de boas-vindas
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() => Text(
                    controller.authService.isLoggedIn
                        ? 'Olá, ${controller.authService.currentUser.value?.firstName ?? 'Jogador(a)'}!'
                        : '🔥 Promoções em Destaque',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  )),
            ),
            const SizedBox(height: 20),

            // Seção de Promoções em Destaque (Carrossel com PageView)
            Obx(() {
              if (controller.isLoadingDeals.value && controller.topDeals.isEmpty) {
                return const Center(child: SizedBox(height: 190, child: CircularProgressIndicator()));
              }
              if (controller.topDeals.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("Nenhuma promoção em destaque.")));
              }
              
              return Column(
                children: [
                  SizedBox(
                    height: 195, // Altura do PageView (ajuste conforme seu SmallDealCardWidget)
                    child: PageView.builder(
                      controller: controller.carouselPageController,
                      itemCount: controller.topDeals.length,
                      onPageChanged: (index) {
                        controller.currentCarouselIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        final deal = controller.topDeals[index];
                        // Adiciona um padding para os itens do PageView se viewportFraction < 1.0
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0), // Espaçamento entre cards
                          child: SmallDealCardWidget(deal: deal),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Indicador de Página
                  if (controller.topDeals.length > 1) // Só mostra indicador se houver mais de 1 item
                    SmoothPageIndicator(
                      controller: controller.carouselPageController,
                      count: controller.topDeals.length,
                      effect: WormEffect( // Experimente outros efeitos: ExpandingDotsEffect, ScrollingDotsEffect
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: Theme.of(context).colorScheme.primary,
                        dotColor: Colors.grey.shade300,
                      ),
                      onDotClicked: (index) {
                        controller.carouselPageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                    ),
                ],
              );
            }),
            const SizedBox(height: 30), // Ajuste o espaçamento

            // Botão de Ação (Login/Cadastro ou Ver Todas as Promoções)
            Padding( // Padding para o botão
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(() {
                if (controller.authService.isLoggedIn) {
                  return ElevatedButton(
                    onPressed: () => MainNavigationController.to.changeTabPage(1),
                    child: const Text('Ver Todas as Promoções'),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: controller.navigateToLogin,
                    child: const Text('Acessar / Cadastrar para Mais'),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}