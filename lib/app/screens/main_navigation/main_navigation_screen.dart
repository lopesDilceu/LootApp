import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => CommonAppBar(
              title: controller.appBarTitle.value, 
              isSecondaryPageActive: controller.isSecondaryPageActive, // Passa o estado
            )),
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
      bottomNavigationBar: Obx(() => controller.showBottomNavBar.value
          ? NavigationBar( 
              onDestinationSelected: controller.changeTabPage,
              selectedIndex: controller.selectedIndex.value,
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.local_offer), 
                  icon: Icon(Icons.local_offer_outlined),
                  label: 'Promoções',
                ),
                NavigationDestination( // Nova aba
                  selectedIcon: Icon(Icons.track_changes), 
                  icon: Icon(Icons.track_changes_outlined),
                  label: 'Monitorar',
                ),
              ],
            )
          : const SizedBox.shrink()),
    );
  }
}