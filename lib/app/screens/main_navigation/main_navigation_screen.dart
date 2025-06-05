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
        child: Obx(
          () => CommonAppBar(
            title: controller.appBarTitle.value,
            isSecondaryPageActive:
                controller.isSecondaryPageActive, // Passa o estado
          ),
        ),
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
                type: BottomNavigationBarType.fixed, // Evita rotação do ícone
                onTap: controller.changeTabPage,
                currentIndex: controller.selectedIndex.value,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: '', // Removendo o label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.local_offer_outlined),
                    activeIcon: Icon(Icons.local_offer),
                    label: '', // Removendo o label
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.track_changes_outlined),
                    activeIcon: Icon(Icons.track_changes),
                    label: '', // Removendo o label
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
