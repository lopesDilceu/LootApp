import 'dart:convert'; // Para jsonEncode e jsonDecode
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/user_model.dart'; // Seu modelo User
import 'package:loot_app/app/routes/app_routes.dart';   // Suas rotas

class AuthService extends GetxService {
  static AuthService get to => Get.find(); // Atalho para acessar a instância

  final _secureStorage = const FlutterSecureStorage();

  // Rxn permite que o valor seja nulo e seja reativo
  final Rxn<User> currentUser = Rxn<User>();
  final RxnString authToken = RxnString(); // Armazena o token JWT

  // Booleano reativo para verificar facilmente se está autenticado
  final RxBool isAuthenticated = false.obs;

  // Getter para facilitar a verificação em outros lugares
  bool get isLoggedIn => isAuthenticated.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    print("[AuthService] Inicializado. Tentando auto-login...");
    await tryAutoLogin(); // Tenta logar o usuário automaticamente ao iniciar o app
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await _secureStorage.read(key: 'authToken');
    final storedUserJson = await _secureStorage.read(key: 'userJson');

    if (storedToken != null && storedUserJson != null) {
      try {
        final userMap = jsonDecode(storedUserJson) as Map<String, dynamic>;
        currentUser.value = User.fromJson(userMap);
        authToken.value = storedToken;
        isAuthenticated.value = true;
        print("[AuthService] Auto-login bem-sucedido para: ${currentUser.value?.email}");
      } catch (e) {
        print("[AuthService] Erro ao decodificar dados do usuário no auto-login: $e");
        await logout(); // Limpa dados inválidos
      }
    } else {
      print("[AuthService] Nenhum token/usuário encontrado para auto-login.");
      isAuthenticated.value = false; // Garante que o estado seja falso
    }
  }

  Future<void> loginUserSession(User user, String token) async {
    currentUser.value = user;
    authToken.value = token;
    isAuthenticated.value = true;

    await _secureStorage.write(key: 'authToken', value: token);
    await _secureStorage.write(key: 'userJson', value: jsonEncode(user.toJson())); // Salva o User como JSON

    print("[AuthService] Usuário ${user.email} logado. Token salvo.");
  }

  Future<void> logout() async {
    currentUser.value = null;
    authToken.value = null;
    isAuthenticated.value = false;

    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'userJson');
    print("[AuthService] Usuário deslogado. Token e dados limpos.");

    // Redireciona para a tela de login (ou home inicial não logada)
    // Usar offAllNamed para limpar a pilha de navegação
    Get.offAllNamed(AppRoutes.LOGIN); 
  }
}