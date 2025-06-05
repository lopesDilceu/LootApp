// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
// DealsController não é mais necessário aqui se a busca da AppBar foi removida
// import 'package:loot_app/app/controllers/deals_controller.dart'; 
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/screens/auth/login_screen_content.dart';
import 'package:loot_app/app/screens/auth/register_screen_content.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; 
  final bool isSecondaryPageActive;

  const CommonAppBar({
    super.key,
    required this.title,
    this.isSecondaryPageActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService.to;
    final MainNavigationController mainNavController = MainNavigationController.to;
    
    return AppBar(
      leading: isSecondaryPageActive
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: "Voltar",
              onPressed: () => mainNavController.closeSecondaryPage(),
            )
          : IconButton( 
              icon: SvgPicture.asset(
                'assets/images/logos/logo-text-dark.svg', // Use 'assets/' para mobile
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 32, height: 32,
                semanticsLabel: "Logo Loot App",
              ),
              tooltip: 'Página Inicial',
              onPressed: () => mainNavController.changeTabPage(0),
            ),
      title: Text(title),
      centerTitle: true, 
      actions: <Widget>[
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
                } else { // Deslogado
                   items.addAll([
                     const PopupMenuItem<String>(value: 'login_page', child: ListTile(leading: Icon(Icons.login), title: Text('Fazer Login'))),
                     const PopupMenuItem<String>(value: 'register_page', child: ListTile(leading: Icon(Icons.person_add_alt_1), title: Text('Cadastrar-se'))),
                     const PopupMenuDivider(),
                     const PopupMenuItem<String>(value: 'settings', child: ListTile(leading: Icon(Icons.settings_outlined), title: Text('Configurações'))),
                   ]);
                }
                
                // Esconde o menu se estiver exibindo Login ou Cadastro como página secundária
                if (mainNavController.secondaryPageContent.value is LoginScreenContent || 
                    mainNavController.secondaryPageContent.value is RegisterScreenContent) {
                    return const SizedBox.shrink();
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
                    else if (value == 'login_page') mainNavController.navigateToLoginPage(); // Manda para a página de conteúdo
                    else if (value == 'register_page') mainNavController.navigateToRegisterPage(); // Manda para a página de conteúdo
                  },
                  itemBuilder: (BuildContext context) => items,
                );
              },
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}