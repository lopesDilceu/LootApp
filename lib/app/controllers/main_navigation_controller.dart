import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';
import 'package:loot_app/app/controllers/profile_controller.dart';
import 'package:loot_app/app/controllers/settings_controller.dart';
import 'package:loot_app/app/data/models/deal_model.dart'; // Para o parâmetro de DealDetail
import 'package:loot_app/app/screens/auth/login_screen_content.dart';
import 'package:loot_app/app/screens/auth/register_screen_content.dart';
import 'package:loot_app/app/screens/home/home_screen_content.dart';
import 'package:loot_app/app/screens/deals/deals_list_screen_content.dart';
import 'package:loot_app/app/screens/monitoring/monitoring_screen_content.dart';
import 'package:loot_app/app/screens/profile/profile_screen_content.dart';
import 'package:loot_app/app/screens/deals/deal_detail_screen_content.dart'; // <<< NOVO CONTEÚDO
// Bindings
import 'package:loot_app/app/bindings/home_binding.dart';
import 'package:loot_app/app/bindings/deals_binding.dart';
import 'package:loot_app/app/bindings/monitoring_binding.dart';
import 'package:loot_app/app/bindings/profile_binding.dart';
import 'package:loot_app/app/bindings/settings_binding.dart';
import 'package:loot_app/app/bindings/auth_binding.dart';
import 'package:loot_app/app/bindings/deal_detail_binding.dart'; // <<< NOVO BINDING
import 'package:loot_app/app/screens/settings/settings_screen_content.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';


class MainNavigationController extends GetxController {
  static MainNavigationController get to => Get.find();

  var selectedIndex = 0.obs;
  final RxString appBarTitle = "LooT".obs;
  final Rx<Widget?> secondaryPageContent = Rxn<Widget>();
  final RxBool showBottomNavBar = true.obs;

  final List<Widget> tabContentPages = [
    const HomeScreenContent(),
    const DealsListScreenContent(),
    const MonitoringScreenContent(),
  ];

  final List<String> _tabTitles = const ["LooT", "Promoções", "Monitoramento"];
  String? _secondaryPageTitle;

  @override
  void onInit() {
    super.onInit();
    print("[MainNavigationController] onInit");
    
    AuthBinding().dependencies();
    HomeBinding().dependencies();
    DealsBinding().dependencies(); 
    MonitoringBinding().dependencies();
    ProfileBinding().dependencies(); 
    SettingsBinding().dependencies();
    DealDetailBinding().dependencies(); // <<< CHAMA O BINDING DE DETALHES

    int initialTab = 0;
    if (Get.arguments is Map && Get.arguments['initialTabIndex'] != null) {
      initialTab = Get.arguments['initialTabIndex'];
    }
    _navigateToTab(initialTab); // Define a página e título iniciais

    ever(AuthService.to.isAuthenticated, _handleAuthChange);
  }

  void _handleAuthChange(bool isLoggedIn) {
    print("[MainNavigationController] Estado de autenticação mudou para: $isLoggedIn");
    if (isLoggedIn) {
      if (secondaryPageContent.value is LoginScreenContent || secondaryPageContent.value is RegisterScreenContent) {
        closeSecondaryPage(); 
        changeTabPage(1);     
        Get.snackbar("Login Realizado", "Bem-vindo(a) de volta!", snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Se deslogou e estava em perfil ou detalhes, volta para a home
      if (secondaryPageContent.value is ProfileScreenContent || secondaryPageContent.value is DealDetailScreenContent) {
         closeSecondaryPage(); 
         changeTabPage(0);
      }
    }
  }

  void _navigateToTab(int index) {
    selectedIndex.value = index;
    _secondaryPageTitle = null; 
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
    _showSecondaryPage(const ProfileScreenContent(), "Meu Perfil");
  }

  void navigateToSettingsPage() {
    _showSecondaryPage(const SettingsScreenContent(), "Configurações");
  }

  void navigateToLoginPage() {
    _showSecondaryPage(const LoginScreenContent(), "Entrar na Conta");
  }

  void navigateToRegisterPage() {
    _showSecondaryPage(const RegisterScreenContent(), "Criar Conta");
  }

  void navigateToDealDetailPage(DealModel deal) {
    print("[MainNavigationController] Preparando para exibir DealDetail com: ${deal.title}");
    
    if (Get.isRegistered<DealDetailController>()) {
      final DealDetailController detailCtrl = Get.find<DealDetailController>();
      detailCtrl.loadDealDetails(deal); // Passa o deal para o controller
      _showSecondaryPage(
          const DealDetailScreenContent(), 
          // Trunca o título se for muito longo para a AppBar
          deal.title.length > 25 ? "${deal.title.substring(0,22)}..." : deal.title 
      );
    } else {
      print("[MainNavigationController] ERRO CRÍTICO: DealDetailController não está registrado! Verifique MainNavigationBinding.");
      Get.snackbar("Erro de Navegação", "Não foi possível abrir os detalhes (erro DC).");
    }
  }

  void closeSecondaryPage() {
    print("[MainNavigationController] Fechando página secundária, voltando para aba: ${selectedIndex.value}");
    
    // Opcional: Limpar o estado do controller da página secundária que foi fechada
    if (secondaryPageContent.value is DealDetailScreenContent && Get.isRegistered<DealDetailController>()) {
      Get.find<DealDetailController>().clearDealDetails();
    } else if (secondaryPageContent.value is ProfileScreenContent && Get.isRegistered<ProfileController>()) {
      // Get.find<ProfileController>().clearProfileData(); // Exemplo
    } else if (secondaryPageContent.value is SettingsScreenContent && Get.isRegistered<SettingsController>()) {
      // Get.find<SettingsController>().resetSomeSetting(); // Exemplo
    }
    // Não precisa limpar para LoginPageContent ou RegisterPageContent, pois o estado de login já foi tratado
    
    _navigateToTab(selectedIndex.value); // Volta para a aba que estava ativa
  }

  bool get isSecondaryPageActive => secondaryPageContent.value != null;
  
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