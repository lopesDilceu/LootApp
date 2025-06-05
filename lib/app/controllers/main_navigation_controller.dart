import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/bindings/auth_binding.dart';
import 'package:loot_app/app/screens/auth/login_screen_content.dart';
import 'package:loot_app/app/screens/auth/register_screen_content.dart';
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
import 'package:loot_app/app/services/auth/auth_service.dart';


class MainNavigationController extends GetxController {
  static MainNavigationController get to => Get.find();

  var selectedIndex = 0.obs; // Para a BottomNavBar
  final RxString appBarTitle = "LooT".obs;
  final Rx<Widget?> secondaryPageContent = Rxn<Widget>(); // Para Profile/Settings
  final RxBool showBottomNavBar = true.obs;

  final List<Widget> tabContentPages = [
    const HomeScreenContent(),
    const DealsListScreenContent(),
    const MonitoringScreenContent(),
  ];

  final List<String> _tabTitles = const [
    "LooT", "Promoções", "Monitoramento",
  ];

  // Título da página secundária quando ativa
  String? _secondaryPageTitle;

  @override
  void onInit() {
    super.onInit();
    print("[MainNavigationController] onInit");
    // Garante que os bindings das abas E das páginas secundárias sejam carregados
    AuthBinding().dependencies();
    HomeBinding().dependencies();
    DealsBinding().dependencies(); 
    MonitoringBinding().dependencies();
    ProfileBinding().dependencies(); 
    SettingsBinding().dependencies(); // Garante que SettingsController esteja disponível

    int initialTab = 0;
    if (Get.arguments is Map && Get.arguments['initialTabIndex'] != null) {
      initialTab = Get.arguments['initialTabIndex'];
    }
    _navigateToTab(initialTab); // Define a página e título iniciais

    // Ouve o estado de autenticação para fechar login/cadastro e ir para uma aba
    ever(AuthService.to.isAuthenticated, _handleAuthChange);
  }


  void _handleAuthChange(bool isLoggedIn) {
    print("[MainNavigationController] Estado de autenticação mudou para: $isLoggedIn");
    if (isLoggedIn) {
      // Se o usuário logou E estava em uma página de login/cadastro secundária, fecha ela
      if (secondaryPageContent.value is LoginScreenContent || secondaryPageContent.value is RegisterScreenContent) {
        closeSecondaryPage(); // Volta para a aba anterior ou a padrão (home)
        changeTabPage(1);     // E então vai para a aba "Promoções" (índice 1)
        Get.snackbar("Login Realizado", "Bem-vindo(a) de volta!", snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Se o usuário deslogou E estava em uma página secundária protegida (como Perfil)
      if (secondaryPageContent.value is ProfileScreenContent) {
         closeSecondaryPage(); // Volta para a aba home
         changeTabPage(0);
      }
      // Se o usuário deslogou, mas não estava numa página secundária,
      // e estava em uma aba que requer login, pode ser interessante redirecionar para a aba Home.
      // Ex: if (selectedIndex.value == 1 /* Deals */) { changeTabPage(0); }
    }
  }

  void _navigateToTab(int index) {
    selectedIndex.value = index;
    _secondaryPageTitle = null; // Garante que não há título de página secundária
    appBarTitle.value = _tabTitles[index];
    secondaryPageContent.value = null; 
    showBottomNavBar.value = true;    
    print("[MainNavigationController] Navegado para aba $index: ${_tabTitles[index]}");
  }

  void changeTabPage(int index) {
    if (index < 0 || index >= tabContentPages.length) return;
    _navigateToTab(index);
  }

  void _showSecondaryPage(Widget content, String title) {
    _secondaryPageTitle = title;
    secondaryPageContent.value = content;
    appBarTitle.value = _secondaryPageTitle!;
    showBottomNavBar.value = false; 
  }

  void navigateToProfilePage() {
    print("[MainNavigationController] Navegando para ProfilePageContent");
    _showSecondaryPage(const ProfileScreenContent(), "Meu Perfil");
  }

  void navigateToSettingsPage() {
    print("[MainNavigationController] Navegando para SettingsPageContent");
    _showSecondaryPage(const SettingsScreenContent(), "Configurações");
  }

  void navigateToLoginPage() {
    print("[MainNavigationController] Navegando para LoginPageContent");
    _showSecondaryPage(const LoginScreenContent(), "Entrar na Conta");
  }

  void navigateToRegisterPage() {
    print("[MainNavigationController] Navegando para RegisterPageContent");
    _showSecondaryPage(const RegisterScreenContent(), "Criar Conta");
  }

  void closeSecondaryPage() {
    print("[MainNavigationController] Fechando página secundária, voltando para aba: ${selectedIndex.value}");
    _navigateToTab(selectedIndex.value); // Volta para a aba que estava ativa
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
    return "LooT App"; // Fallback
  }
}