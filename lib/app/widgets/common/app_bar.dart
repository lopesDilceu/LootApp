// lib/app/widgets/common/app_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? customActions;
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    required this.title,
    this.customActions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: customActions ??
          [
            GetX<AuthService>( // <--- ESTE WIDGET OBSERVA O AuthService
              builder: (authServiceController) { // Recebe a instância do AuthService
                if (authServiceController.isAuthenticated.value) { // <--- VERIFICA SE ESTÁ LOGADO
                  // Se logado, mostra o PopupMenuButton (dropdown)
                  return PopupMenuButton<String>(
                    tooltip: "Opções do Usuário",
                    icon: const Icon(Icons.account_circle), // Ícone para o menu
                    onSelected: (value) {
                      if (value == 'profile') {
                        // Navega para a tela de Perfil
                        Get.toNamed(AppRoutes.PROFILE); 
                      } else if (value == 'logout') {
                        // Chama o método logout do AuthService
                        authServiceController.logout(); 
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text(
                            'Perfil (${authServiceController.currentUser.value?.firstName ?? 'Usuário'})'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Sair'),
                      ),
                    ],
                  );
                } else {
                  // Se não estiver logado, mostra o botão de LOGIN (se não estiver nas telas de auth)
                  final String currentRoute = Get.currentRoute;
                  if (currentRoute != AppRoutes.LOGIN && currentRoute != AppRoutes.REGISTER) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.LOGIN),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(color: Colors.white), // Ajuste conforme seu tema
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Não mostra nada se já estiver em login/cadastro
                }
              },
            ),
            // Lógica para padding (pode ser ajustada ou removida se não for mais necessária)
            if (customActions == null && 
                (AuthService.to.isAuthenticated.value || // Verifica se está logado para o padding
                 (Get.currentRoute != AppRoutes.LOGIN && Get.currentRoute != AppRoutes.REGISTER)))
              const SizedBox(width: 8)
            else if (customActions == null)
              const SizedBox.shrink(),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}