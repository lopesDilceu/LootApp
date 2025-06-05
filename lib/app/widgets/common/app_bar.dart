import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/screens/profile/profile_screen_content.dart';
import 'package:loot_app/app/screens/settings/settings_screen_content.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
// import 'package:loot_app/app/services/auth_service.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; 
  final bool isSecondaryPageActive;
  // O parâmetro showLogoAsHomeButton foi removido, o logo é sempre mostrado
  // a menos que seja uma página secundária (onde o botão voltar aparece)

  const CommonAppBar({
    super.key,
    required this.title,
    this.isSecondaryPageActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // final AuthService authService = AuthService.to;
    final MainNavigationController mainNavController = MainNavigationController.to;
    
    return AppBar(
      leading: isSecondaryPageActive
          ? IconButton( // Botão de voltar para páginas secundárias (Perfil, Configurações)
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: "Voltar",
              onPressed: () => mainNavController.closeSecondaryPage(),
            )
          : IconButton( // Logo que leva para a aba Home
              icon: SvgPicture.asset(
                'assets/images/logos/logo-text-dark.svg', // Caminho para seu logo SVG
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 32, height: 32,
                semanticsLabel: "Logo LooT App",
              ),
              tooltip: 'Página Inicial',
              onPressed: () {
                mainNavController.changeTabPage(0); // Vai para aba Home (índice 0)
              },
            ),
      
      title: Text(title), // Título é sempre o texto passado
      centerTitle: true, 

      actions: <Widget>[
            // Ações customizadas (como o botão de filtro) podem ser adicionadas aqui pela MainNavigationScreen
            // se necessário, ou diretamente se a CommonAppBar precisar ser mais inteligente sobre a aba atual.
            // Por ora, apenas o menu de usuário/login/configurações.

            GetX<AuthService>(
              builder: (authCtrl) {
                List<PopupMenuEntry<String>> items = [];
                if (authCtrl.isLoggedIn) {
                  items.addAll([
                    const PopupMenuItem<String>(value: 'deals_list_tab', child: Text('Promoções')),
                    PopupMenuItem<String>(value: 'profile', child: Text('Perfil (${authCtrl.currentUser.value?.firstName ?? 'Usuário'})')),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configurações'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(value: 'logout', child: Text('Sair')),
                  ]);
                } else {
                   items.addAll([
                     const PopupMenuItem<String>(value: 'login', child: ListTile(leading: Icon(Icons.login), title: Text('Fazer Login'))),
                     const PopupMenuDivider(),
                     const PopupMenuItem<String>(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configurações'))),
                   ]);
                }
                
                final String currentRouteName = Get.currentRoute;
                bool onAuthScreenItself = currentRouteName == AppRoutes.LOGIN || currentRouteName == AppRoutes.REGISTER;
                
                if (onAuthScreenItself || (isSecondaryPageActive && !authCtrl.isLoggedIn && _getSecondaryPageType(mainNavController) != SecondaryPageType.settings) ) {
                    return const SizedBox.shrink();
                }
                if (_getSecondaryPageType(mainNavController) == SecondaryPageType.settings && !authCtrl.isLoggedIn){
                   items = [const PopupMenuItem<String>(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configurações')))];
                }

                return PopupMenuButton<String>(
                  tooltip: authCtrl.isLoggedIn ? "Opções do Usuário" : "Opções",
                  icon: Icon(authCtrl.isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined),
                  offset: const Offset(0, kToolbarHeight - 10),
                  onSelected: (value) {
                    if (value == 'deals_list_tab') mainNavController.changeTabPage(1);
                    else if (value == 'profile') mainNavController.navigateToProfilePage();
                    else if (value == 'settings') mainNavController.navigateToSettingsPage();
                    else if (value == 'logout') authCtrl.logout();
                    else if (value == 'login') Get.toNamed(AppRoutes.LOGIN);
                  },
                  itemBuilder: (BuildContext context) => items,
                );
              },
            ),
            const SizedBox(width: 8), // Padding final
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  SecondaryPageType _getSecondaryPageType(MainNavigationController mainNavController) {
    if (mainNavController.secondaryPageContent.value is ProfileScreenContent) {
      return SecondaryPageType.profile;
    } else if (mainNavController.secondaryPageContent.value is SettingsScreenContent) {
      return SecondaryPageType.settings;
    }
    return SecondaryPageType.none;
  }
}

enum SecondaryPageType { none, profile, settings }