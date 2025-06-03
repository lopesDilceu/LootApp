// lib/app/services/auth_service.dart
import 'dart:convert'; // Para jsonEncode e jsonDecode
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/user_model.dart'; // Seu modelo User
import 'package:loot_app/app/routes/app_routes.dart';   // Suas rotas

class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final _secureStorage = const FlutterSecureStorage();
  final Rxn<User> currentUser = Rxn<User>();
  final RxnString authToken = RxnString();
  final RxBool isAuthenticated = false.obs;
  
  final RxBool _isInitialized = false.obs;
  bool get isServiceInitialized => _isInitialized.value;

  // Getter para conveniência e clareza
  bool get isLoggedIn => isAuthenticated.value;

  Future<AuthService> init() async {
    print("[AuthService] Método init() customizado - INÍCIO");
    try {
      await tryAutoLogin();
    } catch (e, stackTrace) {
      print("[AuthService] ERRO CRÍTICO DENTRO DE init() ao chamar tryAutoLogin: $e");
      print("[AuthService] StackTrace do erro em init(): $stackTrace");
      isAuthenticated.value = false; 
    }
    _isInitialized.value = true;
    print("[AuthService] Método init() customizado - FIM. Autenticado: ${isAuthenticated.value}"); // Use .value aqui
    return this;
  }

  @override
  void onInit() {
    super.onInit();
    print("[AuthService] GetxService onInit() chamado (síncrono).");
  }

  Future<void> tryAutoLogin() async {
    print("[AuthService] tryAutoLogin - INÍCIO");
    String? storedToken;
    String? storedUserJson;

    try {
      print("[AuthService] tryAutoLogin - Lendo 'authToken' do secureStorage...");
      storedToken = await _secureStorage.read(key: 'authToken');
      print("[AuthService] tryAutoLogin - 'authToken' lido: ${storedToken != null ? 'ENCONTRADO (${storedToken.substring(0,5)}...)' : 'NULO'}");

      print("[AuthService] tryAutoLogin - Lendo 'userJson' do secureStorage...");
      storedUserJson = await _secureStorage.read(key: 'userJson');
      print("[AuthService] tryAutoLogin - 'userJson' lido: ${storedUserJson != null ? 'ENCONTRADO' : 'NULO'}");

    } catch (e, stackTrace) {
      print("[AuthService] tryAutoLogin - ERRO AO LER DO SECURESTORAGE: $e");
      print("[AuthService] StackTrace do erro no secureStorage: $stackTrace");
      isAuthenticated.value = false;
      print("[AuthService] tryAutoLogin - FIM (devido a erro na leitura do storage)");
      return;
    }

    if (storedToken != null && storedUserJson != null) {
      print("[AuthService] tryAutoLogin - Token e UserJson encontrados. Tentando parsear...");
      try {
        final userMap = jsonDecode(storedUserJson) as Map<String, dynamic>;
        currentUser.value = User.fromJson(userMap);
        authToken.value = storedToken;
        isAuthenticated.value = true;
        print("[AuthService] tryAutoLogin - Auto-login BEM-SUCEDIDO para: ${currentUser.value?.email}");
      } catch (e, stackTrace) {
        print("[AuthService] tryAutoLogin - ERRO AO DECODIFICAR/PARSEAR UserJson: $e");
        print("[AuthService] StackTrace do erro no parse: $stackTrace");
        try {
          await _secureStorage.delete(key: 'authToken');
          await _secureStorage.delete(key: 'userJson');
        } catch (delErr) { print("Erro ao limpar storage após parse error: $delErr");}
        isAuthenticated.value = false;
      }
    } else {
      print("[AuthService] tryAutoLogin - Nenhum token ou userJson válido encontrado para auto-login.");
      isAuthenticated.value = false;
    }
    print("[AuthService] tryAutoLogin - FIM. isAuthenticated: ${isAuthenticated.value}");
  }

  Future<void> loginUserSession(User user, String token) async {
    print("[AuthService] loginUserSession - INÍCIO para usuário: ${user.email}");
    currentUser.value = user;
    authToken.value = token;
    isAuthenticated.value = true; // Define como logado na memória primeiro

    try {
      print("[AuthService] loginUserSession - Tentando salvar 'authToken': $token");
      await _secureStorage.write(key: 'authToken', value: token);
      print("[AuthService] loginUserSession - 'authToken' salvo (ou tentativa concluída).");

      final userJson = jsonEncode(user.toJson());
      print("[AuthService] loginUserSession - Tentando salvar 'userJson': $userJson");
      await _secureStorage.write(key: 'userJson', value: userJson);
      print("[AuthService] loginUserSession - 'userJson' salvo (ou tentativa concluída).");

      // Verificação imediata (para debug no web)
      final checkToken = await _secureStorage.read(key: 'authToken');
      final checkUser = await _secureStorage.read(key: 'userJson');
      print("[AuthService] loginUserSession - Verificação APÓS write: Token: ${checkToken!=null}, User: ${checkUser!=null}");
      if (checkToken == null || checkUser == null) {
          print("[AuthService] loginUserSession - ALERTA: Falha ao persistir dados no secureStorage!");
      }

    } catch (e, stackTrace) {
      print("[AuthService] loginUserSession - ERRO AO SALVAR NO SECURESTORAGE: $e");
      print("[AuthService] StackTrace do erro ao salvar: $stackTrace");
      // Mesmo se falhar ao salvar, o usuário está logado na sessão atual em memória.
      // Mas o auto-login não funcionará.
    }
    print("[AuthService] loginUserSession - FIM. isAuthenticated: ${isAuthenticated.value}");
  }

  Future<void> logout() async {
    // ... (seu método logout com logs como estava antes) ...
    currentUser.value = null;
    authToken.value = null;
    isAuthenticated.value = false;

    try {
      print("[AuthService] Deletando token e userJson do secureStorage...");
      await _secureStorage.delete(key: 'authToken');
      await _secureStorage.delete(key: 'userJson');
      print("[AuthService] Token e userJson deletados.");
    } catch (e, stackTrace) {
      print("[AuthService] ERRO ao deletar do secureStorage em logout: $e");
      print("[AuthService] StackTrace do erro ao deletar: $stackTrace");
    }
    print("[AuthService] Usuário deslogado.");
    Get.offAllNamed(AppRoutes.MAIN_NAVIGATION, arguments: {'initialTabIndex': 0}); 
  }
}