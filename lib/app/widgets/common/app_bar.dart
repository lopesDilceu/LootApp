// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Para seu logo SVG
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
// ThemeService não é mais necessário aqui para um botão de tema dedicado,
// mas a tela de Configurações o usará.

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>?
  customActions; // Ações personalizadas que a tela pode querer adicionar

  const CommonAppBar({super.key, required this.title, this.customActions});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService.to;

    return AppBar(
      leading: IconButton(
        icon: SvgPicture.asset(
          'images/logos/logo-text-dark.svg', // <<< SEU CAMINHO PARA O LOGO SVG (SEM 'assets/' inicial)
          width: 32,
          height: 32,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          semanticsLabel: 'Logo Loot App',
        ),
        tooltip: 'Página Inicial Loot',
        onPressed: () {
          print("[CommonAppBar] Botão de Logo pressionado.");
          // Lógica para ir para a HOME (primeira aba da MainNavigationScreen se estiver usando,
          // ou AppRoutes.HOME diretamente se não).
          // Simplificando, sempre vai para AppRoutes.HOME e a Splash/MainNavigation cuida do resto.
          if (Get.currentRoute != AppRoutes.HOME) {
            // Evita recarregar a home se já estiver nela
            // Se estiver usando MainNavigation, o ideal seria:
            // if (Get.isRegistered<MainNavigationController>()) {
            //   Get.find<MainNavigationController>().changeTabPage(0);
            // } else {
            //   Get.offAllNamed(AppRoutes.HOME);
            // }
            // Por ora, simples:
            Get.offAllNamed(AppRoutes.HOME);
          }
        },
      ),
      title: Text(title),
      centerTitle: true,
      actions:
          customActions ?? // Se não houver ações customizadas, usa o menu padrão
          [
            // O ícone de busca e o campo de texto da AppBar foram removidos desta versão
            // para focar apenas no menu de usuário/configurações.
            // Se precisar da busca na AppBar, ela precisaria ser reintegrada com cuidado
            // para não conflitar com o menu de usuário e o customActions.

            // Menu de Usuário/Login/Configurações
            GetX<AuthService>(
              builder: (authCtrl) {
                if (authCtrl.isLoggedIn) {
                  // --- USUÁRIO LOGADO ---
                  return PopupMenuButton<String>(
                    tooltip: "Opções do Usuário",
                    icon: const Icon(Icons.account_circle),
                    offset: const Offset(0, kToolbarHeight - 10),
                    onSelected: (value) {
                      if (value == 'deals_list') {
                        // Se estiver usando MainNavigationScreen:
                        // if (Get.isRegistered<MainNavigationController>()) {
                        //   Get.find<MainNavigationController>().changeTabPage(1); // Supondo que Deals é aba 1
                        // } else
                        if (Get.currentRoute != AppRoutes.DEALS_LIST) {
                          Get.toNamed(AppRoutes.DEALS_LIST);
                        }
                      } else if (value == 'profile') {
                        if (Get.currentRoute != AppRoutes.PROFILE) {
                          Get.toNamed(AppRoutes.PROFILE);
                        }
                      } else if (value == 'settings') {
                        // <<< OPÇÃO DE CONFIGURAÇÕES
                        Get.toNamed(AppRoutes.SETTINGS);
                      } else if (value == 'logout') {
                        authCtrl.logout();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'deals_list',
                        child: Text('Minhas Promoções'),
                      ),
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text(
                          'Perfil (${authCtrl.currentUser.value?.firstName ?? 'Usuário'})',
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        // <<< ITEM "CONFIGURAÇÕES"
                        value: 'settings',
                        child: ListTile(
                          leading: Icon(Icons.settings_outlined),
                          title: Text('Configurações'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Sair'),
                      ),
                    ],
                  );
                } else {
                  // --- USUÁRIO DESLOGADO ---
                  final String currentRoute = Get.currentRoute;
                  if (currentRoute != AppRoutes.LOGIN &&
                      currentRoute != AppRoutes.REGISTER) {
                    return PopupMenuButton<String>(
                      tooltip: "Opções",
                      icon: const Icon(
                        Icons.account_circle_outlined,
                      ), // Ícone para deslogado
                      offset: const Offset(0, kToolbarHeight - 10),
                      onSelected: (value) {
                        if (value == 'login') {
                          Get.toNamed(AppRoutes.LOGIN);
                        } else if (value == 'settings') {
                          // <<< OPÇÃO DE CONFIGURAÇÕES
                          Get.toNamed(AppRoutes.SETTINGS);
                        }
                        // Adicionar 'register' se quiser essa opção no menu
                        // else if (value == 'register') { Get.toNamed(AppRoutes.REGISTER); }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'login',
                              child: ListTile(
                                leading: Icon(Icons.login),
                                title: Text('Fazer Login'),
                              ),
                            ),
                            // Opcional: Adicionar Cadastro aqui se desejar
                            // const PopupMenuItem<String>(
                            //   value: 'register',
                            //   child: ListTile(leading: Icon(Icons.person_add_alt_1_outlined), title: Text('Cadastrar-se')),
                            // ),
                            const PopupMenuDivider(),
                            const PopupMenuItem<String>(
                              // <<< ITEM "CONFIGURAÇÕES"
                              value: 'settings',
                              child: ListTile(
                                leading: Icon(Icons.settings_outlined),
                                title: Text('Configurações'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                    );
                  }
                  return const SizedBox.shrink(); // Não mostra nada se já estiver em Login/Cadastro
                }
              },
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
