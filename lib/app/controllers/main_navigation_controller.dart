import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/screens/home/home_screen_content.dart';
import 'package:loot_app/app/screens/deals/deals_list_screen_content.dart';
import 'package:loot_app/app/screens/monitoring/monitoring_screen_content.dart';
import 'package:loot_app/app/screens/profile/profile_screen_content.dart';
// Bindings para garantir que os controllers sejam inicializados
import 'package:loot_app/app/bindings/home_binding.dart';
import 'package:loot_app/app/bindings/deals_binding.dart';
import 'package:loot_app/app/bindings/monitoring_binding.dart';
import 'package:loot_app/app/bindings/profile_binding.dart';
import 'package:loot_app/app/bindings/settings_binding.dart';
import 'package:loot_app/app/screens/settings/settings_screen_content.dart';


class MainNavigationController extends GetxController {
  static MainNavigationController get to => Get.find();

  var selectedIndex = 0.obs; // Para a BottomNavBar
  final RxString appBarTitle = "Loot".obs;
  final Rx<Widget?> secondaryPageContent = Rxn<Widget>(); // Para Profile/Settings
  final RxBool showBottomNavBar = true.obs;

  final List<Widget> tabContentPages = [
    const HomeScreenContent(),
    const DealsListScreenContent(),
    const MonitoringScreenContent(),
  ];

  final List<String> _tabTitles = const [
    "Loot", "Promoções", "Monitoramento",
  ];

  // Título da página secundária quando ativa
  String? _secondaryPageTitle;

  @override
  void onInit() {
    super.onInit();
    print("[MainNavigationController] onInit");
    // Garante que os bindings das abas E das páginas secundárias sejam carregados
    HomeBinding().dependencies();
    DealsBinding().dependencies(); 
    MonitoringBinding().dependencies();
    ProfileBinding().dependencies(); 
    SettingsBinding().dependencies(); // Garante que SettingsController esteja disponível

    int initialTab = 0;
    if (Get.arguments is Map && Get.arguments['initialTabIndex'] != null) {
      initialTab = Get.arguments['initialTabIndex'];
    }
    changeTabPage(initialTab, fromInit: true);
  }

  void changeTabPage(int index, {bool fromInit = false}) {
    if (index < 0 || index >= tabContentPages.length) return;
    
    print("[MainNavigationController] Trocando para aba: $index - ${_tabTitles[index]}");
    selectedIndex.value = index;
    appBarTitle.value = _tabTitles[index];
    secondaryPageContent.value = null; // Limpa qualquer página secundária
    showBottomNavBar.value = true;    // Garante que a bottom nav seja mostrada
  }

  void navigateToProfilePage() {
    print("[MainNavigationController] Navegando para ProfilePageContent");
    _secondaryPageTitle = "Meu Perfil";
    secondaryPageContent.value = const ProfileScreenContent(); // Usa o widget de conteúdo
    appBarTitle.value = _secondaryPageTitle!;
    showBottomNavBar.value = false; // Esconde a BottomNav
  }

  void navigateToSettingsPage() {
    print("[MainNavigationController] Navegando para SettingsPageContent");
    _secondaryPageTitle = "Configurações";
    secondaryPageContent.value = const SettingsScreenContent(); // Usa o widget de conteúdo
    appBarTitle.value = _secondaryPageTitle!;
    showBottomNavBar.value = false; // Esconde a BottomNav
  }

  void closeSecondaryPage() {
    print("[MainNavigationController] Fechando página secundária, voltando para aba: ${selectedIndex.value}");
    secondaryPageContent.value = null;
    _secondaryPageTitle = null;
    appBarTitle.value = _tabTitles[selectedIndex.value]; // Restaura título da aba
    showBottomNavBar.value = true;
  }

  // Getter para a CommonAppBar saber se uma página secundária está ativa
  bool get isSecondaryPageActive => secondaryPageContent.value != null;
  
  // Getter para o título atual, usado pela CommonAppBar se não estiver em modo de busca
  String get currentAppBarTitle {
    if (isSecondaryPageActive && _secondaryPageTitle != null) {
      return _secondaryPageTitle!;
    }
    if (selectedIndex.value >= 0 && selectedIndex.value < _tabTitles.length) {
      return _tabTitles[selectedIndex.value];
    }
    return "Loot App"; // Fallback
  }
}