import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,  // importante para captar toques em áreas vazias
      onTap: () {
        FocusScope.of(context).unfocus();  // tira o foco do TextField
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Obx(() {
            bool showSearch = controller.selectedIndex.value == 1; // aba promoções

            return CommonAppBar(
              isSecondaryPageActive: controller.isSecondaryPageActive,
              showSearchBar: showSearch,
              onSearchSubmitted: (query) {
                final dealsController = Get.find<DealsController>();
                dealsController.searchGamesByTitleInScreen(query);
              },
            );
          }),
        ),
        body: Obx(() {
          if (controller.secondaryPageContent.value != null) {
            return controller.secondaryPageContent.value!;
          }
          return IndexedStack(
            index: controller.selectedIndex.value,
            children: controller.tabContentPages,
          );
        }),
        bottomNavigationBar: Obx(
          () => controller.showBottomNavBar.value
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  onTap: controller.changeTabPage,
                  currentIndex: controller.selectedIndex.value,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.local_offer_outlined),
                      activeIcon: Icon(Icons.local_offer),
                      label: 'Promoções',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.track_changes_outlined),
                      activeIcon: Icon(Icons.track_changes),
                      label: 'Monitorar',
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
