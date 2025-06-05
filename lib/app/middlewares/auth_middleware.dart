import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1; // Prioridade do middleware

  @override
  RouteSettings? redirect(String? route) {
    // É mais seguro buscar a instância do AuthService aqui dentro
    // para garantir que ele já foi inicializado pelo Get.putAsync no main.dart
    final AuthService authService = AuthService.to; 

    // Log para verificar se o middleware está rodando e o estado de login
    print("[AuthMiddleware] Rota interceptada: $route");
    print("[AuthMiddleware] AuthService inicializado: ${authService.isServiceInitialized}");
    print("[AuthMiddleware] Usuário está logado (isLoggedIn): ${authService.isLoggedIn}"); // Ou authService.isAuthenticated.value

    if (!authService.isLoggedIn) { // Ou !authService.isAuthenticated.value
      // Opcional: Salvar a rota que o usuário tentou acessar para redirecionar de volta após o login
      // Ex: Get.find<SomeStorageService>().intendedRoute = route;
      return const RouteSettings(name: AppRoutes.MAIN_NAVIGATION);
    }
    
    print("[AuthMiddleware] Usuário LOGADO. Permitindo acesso à rota $route.");
    return null; // Nenhuma alteração, permite o acesso à rota original
  }
}