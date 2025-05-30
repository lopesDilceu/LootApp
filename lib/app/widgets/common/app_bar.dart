// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart'; // Certifique-se que o caminho para AuthService está correto

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? customActions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.customActions,
  });

  @override
  Widget build(BuildContext context) {
    // A instância do AuthService é obtida uma vez para evitar múltiplas chamadas a Get.find()
    // AuthService.to já faz isso, mas para clareza no build:
    final AuthService authService = AuthService.to; 

    return AppBar(
      leading: IconButton(
        // Substitua 'Icons.shield_outlined' pelo seu widget de Logo (ex: Image.asset)
        icon: const Icon(Icons.shield_outlined, color: Colors.white),
        tooltip: 'Página Inicial Loot',
        onPressed: () {
          print("[CommonAppBar] Botão de Logo pressionado.");
          // Lógica do usuário: logo sempre leva para AppRoutes.HOME pública.
          // Se quiser que vá para AppRoutes.DEALS_LIST se logado,
          // use: final targetRoute = authService.isLoggedIn ? AppRoutes.DEALS_LIST : AppRoutes.HOME;
          const String targetRoute = AppRoutes.HOME; // Simplificado conforme seu código
          if (Get.currentRoute != targetRoute) {
            Get.offAllNamed(targetRoute);
          } else {
            print("[CommonAppBar] Já está na rota de destino: $targetRoute");
            // Poderia implementar um refresh aqui se desejado, por exemplo, chamando um método do controller da home.
          }
        },
      ),
      title: Text(title),
      centerTitle: true,
      actions: customActions ?? // Se não houver ações customizadas, usa o menu padrão
          [
            GetX<AuthService>(
              builder: (authCtrl) { // authCtrl é a instância do AuthService fornecida pelo GetX builder
                if (authCtrl.isLoggedIn) {
                  // --- USUÁRIO LOGADO ---
                  return PopupMenuButton<String>(
                    tooltip: "Opções do Usuário",
                    icon: const Icon(Icons.account_circle), // Ícone quando logado
                    offset: const Offset(0, kToolbarHeight - 10), // Desloca o menu para baixo
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
                        child: Text('Perfil (${authCtrl.currentUser.value?.firstName ?? 'Usuário'})'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Sair'),
                      ),
                    ],
                  );
                } else {
                  // --- USUÁRIO DESLOGADO ---
                  final String currentRoute = Get.currentRoute;
                  // Só mostra o botão/menu de login se não estiver nas telas de Login ou Cadastro
                  if (currentRoute != AppRoutes.LOGIN && currentRoute != AppRoutes.REGISTER) {
                    return PopupMenuButton<String>(
                      tooltip: "Acessar Conta",
                      icon: const Icon(Icons.account_circle_outlined), // Ícone diferente ou o mesmo (Icons.account_circle)
                      offset: const Offset(0, kToolbarHeight - 10), // Desloca o menu para baixo
                      onSelected: (value) {
                        if (value == 'login') {
                          // Get.currentRoute != AppRoutes.LOGIN já foi checado acima,
                          // mas uma dupla verificação não prejudica se a lógica mudar.
                          Get.toNamed(AppRoutes.LOGIN);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'login',
                          child: Text('Login'),
                        ),
                        // Poderia adicionar "Cadastrar-se" aqui também se quisesse
                        // const PopupMenuItem<String>(
                        //   value: 'register',
                        //   child: Text('Cadastrar-se'),
                        // ),
                      ],
                    );
                  }
                  return const SizedBox.shrink(); // Não mostra nada se já estiver em Login/Cadastro
                }
              },
            ),
            // Adiciona um pequeno espaçamento à direita se o menu de ações padrão for renderizado
            const SizedBox(width: 8), 
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}