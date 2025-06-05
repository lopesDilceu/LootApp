import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/widgets/common/loading_card.dart';
import 'package:loot_app/app/widgets/deals/small_deal_card_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importe o indicador

class HomeScreenContent extends GetView<HomeController> {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.9; // 80% da largura da tela
    final double cardHeight = 180; // altura fixa para evitar overflow

    print(
      "[HomeScreenContent] build. Usuário Logado: ${controller.authService.isLoggedIn}",
    );
    return RefreshIndicator(
      onRefresh: controller.refreshHomepageDeals,
      child: SingleChildScrollView(
        key: const PageStorageKey('homeScreenScroll'),
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
        ), // Padding vertical apenas
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: controller.authService.isLoggedIn
                  ? Obx(
                      () => Text(
                        'Olá, ${controller.authService.currentUser.value?.firstName ?? 'Jogador(a)'}!',
                        textAlign: TextAlign.center,
                        style: Get.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SizedBox.shrink(), // Ou outro widget caso o usuário não esteja logado
            ),

            const SizedBox(height: 20),

            Obx(() {
              if (controller.isLoadingDeals.value &&
                  controller.topDeals.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: cardWidth, // Definindo a largura do card
                    height: cardHeight, // Definindo a altura do card
                    child: LoadingCardWidget(
                      height: cardHeight, // Altura do card
                      width: cardWidth, // Largura do card
                    ),
                  ),
                );
              }
              if (controller.topDeals.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Nenhuma promoção em destaque."),
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: 195, // Altura do PageView
                    child: PageView.builder(
                      controller: controller.carouselPageController,
                      itemCount: controller.topDeals.length,
                      onPageChanged: (index) {
                        controller.currentCarouselIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        final deal = controller.topDeals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: SmallDealCardWidget(deal: deal),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Indicador de Página
                  if (controller.topDeals.length >
                      1) // Só mostra indicador se houver mais de 1 item
                    SmoothPageIndicator(
                      controller: controller.carouselPageController,
                      count: controller.topDeals.length,
                      effect: WormEffect(
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
            Padding(
              // Padding para o botão
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child:  ElevatedButton(
                    onPressed: () =>
                        MainNavigationController.to.changeTabPage(1),
                    child: const Text('Ver Tudo'),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
