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


class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isSecondaryPageActive;
  final bool showSearchBar;
  final Function(String)? onSearchSubmitted;

  const CommonAppBar({
    super.key,
    this.isSecondaryPageActive = false,
    this.showSearchBar = false,
    this.onSearchSubmitted,
  });

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppBarState extends State<CommonAppBar> {
  late final TextEditingController _searchTEC;
  
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchTEC = TextEditingController();
    _searchTEC.addListener(() {
      final hasTextNow = _searchTEC.text.isNotEmpty;
      print('Texto digitado: ${_searchTEC.text}, hasTextNow: $hasTextNow');
      if (hasTextNow != _hasText) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainNavController = MainNavigationController.to;

    return AppBar(
      leading: widget.isSecondaryPageActive
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: "Voltar",
              onPressed: () => mainNavController.closeSecondaryPage(),
            )
          : IconButton(
              icon: SvgPicture.asset(
                'assets/images/logos/logo-text-dark.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 32,
                height: 32,
                semanticsLabel: "Logo Loot App",
              ),
              tooltip: 'Página Inicial',
              onPressed: () => mainNavController.changeTabPage(0),
            ),
      title: widget.showSearchBar
          ? TextField(
              controller: _searchTEC,
              autofocus: false,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar promoções...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: InputBorder.none,
                suffixIcon: _hasText
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          _searchTEC.clear();
                          // Se quiser, pode chamar o onSearchSubmitted com string vazia:
                          if (widget.onSearchSubmitted != null) {
                            widget.onSearchSubmitted!('');
                          }
                        },
                      )
                    : const Icon(Icons.search, color: Colors.white),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (widget.onSearchSubmitted != null) {
                  widget.onSearchSubmitted!(value);
                }
              },
            )
          : null,
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
}
