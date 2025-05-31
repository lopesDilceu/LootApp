// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
import 'package:loot_app/app/services/theme_service.dart'; // Certifique-se que o caminho para AuthService está correto

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? customActions;

  const CommonAppBar({super.key, required this.title, this.customActions});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService.to;
    final ThemeService themeService = ThemeService.to; // Acesso ao ThemeService

    return AppBar(
      leading: IconButton(
        icon: SvgPicture.asset(
          'images/logos/logo-text-dark.svg', // <<< CAMINHO PARA SEU LOGO SVG
          width: 64, // Ajuste a largura conforme necessário
          height: 64, // Ajuste a altura conforme necessário
          // O colorFilter tentará tingir seu SVG. Se o SVG já tiver as cores corretas
          // ou for multicolorido e você quiser preservar as cores, remova ou ajuste o colorFilter.
          // Se o SVG for preto e você quiser branco na AppBar:
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          semanticsLabel: 'Logo Loot App',
        ),
        tooltip: 'Página Inicial Loot',
        onPressed: () {
          const String targetRoute = AppRoutes.HOME;
          if (Get.currentRoute != targetRoute) {
            Get.offAllNamed(targetRoute);
          }
        },
      ),
      title: Text(title),
      centerTitle: true,
      actions:
          customActions ??
          [
            // Botão para Mudar Tema (sempre visível)
            Obx(() {
              // Obx para reagir às mudanças no tema aplicado
              // Usa a variável reativa do ThemeService
              ThemeMode themeModeToShow =
                  themeService.currentAppliedThemeMode.value;
              IconData currentThemeIcon;
              String currentThemeTooltip;

              // Lógica para determinar o ícone e tooltip com base no tema ATUALMENTE APLICADO
              // Se for 'system', precisamos verificar o brilho da plataforma.
              if (themeModeToShow == ThemeMode.system) {
                var platformBrightness = MediaQuery.platformBrightnessOf(
                  context,
                ); // Pega o brilho atual do sistema
                if (platformBrightness == Brightness.dark) {
                  currentThemeIcon = Icons
                      .brightness_auto; // Ou um ícone específico para "sistema escuro"
                  currentThemeTooltip = "Tema: Sistema (Escuro)";
                } else {
                  currentThemeIcon = Icons
                      .brightness_auto_outlined; // Ou um ícone específico para "sistema claro"
                  currentThemeTooltip = "Tema: Sistema (Claro)";
                }
              } else if (themeModeToShow == ThemeMode.dark) {
                currentThemeIcon = Icons.dark_mode;
                currentThemeTooltip = "Tema Atual: Escuro";
              } else {
                // ThemeMode.light
                currentThemeIcon = Icons.light_mode;
                currentThemeTooltip = "Tema Atual: Claro";
              }

              return PopupMenuButton<ThemeMode>(
                icon: Icon(currentThemeIcon), // Ícone dinâmico
                tooltip: currentThemeTooltip, // Tooltip dinâmico
                offset: const Offset(0, kToolbarHeight - 10),
                onSelected: (ThemeMode result) {
                  themeService.switchThemeMode(
                    result,
                  ); // Chama o método do ThemeService
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<ThemeMode>>[
                      const PopupMenuItem<ThemeMode>(
                        value: ThemeMode.light,
                        child: ListTile(
                          leading: Icon(Icons.light_mode_outlined),
                          title: Text('Claro'),
                        ),
                      ),
                      const PopupMenuItem<ThemeMode>(
                        value: ThemeMode.dark,
                        child: ListTile(
                          leading: Icon(Icons.dark_mode_outlined),
                          title: Text('Escuro'),
                        ),
                      ),
                      const PopupMenuItem<ThemeMode>(
                        value: ThemeMode.system,
                        child: ListTile(
                          leading: Icon(Icons.settings_brightness_outlined),
                          title: Text('Sistema'),
                        ),
                      ),
                    ],
              );
            }),
            // Botão de conta do usuário
            GetX<AuthService>(
              builder: (authCtrl) {
                if (authCtrl.isLoggedIn) {
                  return PopupMenuButton<String>(
                    tooltip: "Opções do Usuário",
                    icon: const Icon(Icons.account_circle),
                    offset: const Offset(0, kToolbarHeight - 10),
                    onSelected: (value) {
                      if (value == 'deals_list') {
                        if (Get.currentRoute != AppRoutes.DEALS_LIST) {
                          Get.toNamed(AppRoutes.DEALS_LIST);
                        }
                      } else if (value == 'profile') {
                        if (Get.currentRoute != AppRoutes.PROFILE) {
                          Get.toNamed(AppRoutes.PROFILE);
                        }
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
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Sair'),
                      ),
                    ],
                  );
                } else {
                  final String currentRoute = Get.currentRoute;
                  if (currentRoute != AppRoutes.LOGIN &&
                      currentRoute != AppRoutes.REGISTER) {
                    return PopupMenuButton<String>(
                      tooltip: "Acessar Conta",
                      icon: const Icon(Icons.account_circle_outlined),
                      offset: const Offset(0, kToolbarHeight - 10),
                      onSelected: (value) {
                        if (value == 'login') {
                          Get.toNamed(AppRoutes.LOGIN);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'login',
                              child: Text('Login'),
                            ),
                          ],
                    );
                  }
                  return const SizedBox.shrink();
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
