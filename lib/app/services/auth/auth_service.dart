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
  

  // Flag para saber se a inicialização async está completa
  final RxBool _isInitialized = false.obs;
  bool get isServiceInitialized => _isInitialized.value;

  // Método de inicialização assíncrono customizado
  Future<AuthService> init() async {
    print("[AuthService] Método init() customizado - INÍCIO");
    try {
      await tryAutoLogin();
    } catch (e, stackTrace) { // Captura a exceção e o stack trace
      print("[AuthService] ERRO CRÍTICO DENTRO DE init() ao chamar tryAutoLogin: $e");
      print("[AuthService] StackTrace do erro em init(): $stackTrace");
      // Mesmo com erro no tryAutoLogin, precisamos marcar como inicializado
      // para não travar o Get.putAsync, mas o estado de autenticado será false.
      isAuthenticated.value = false; 
    }
    _isInitialized.value = true;
    print("[AuthService] Método init() customizado - FIM. Autenticado: ${isAuthenticated.value}");
    return this;
  }

  // onInit é chamado automaticamente por GetX, mas não colocaremos async pesado aqui
  @override
  void onInit() {
    super.onInit();
    print("[AuthService] GetxService onInit() chamado (síncrono).");
    // O init() customizado será chamado explicitamente pelo Get.putAsync
  }

  Future<void> tryAutoLogin() async {
    print("[AuthService] tryAutoLogin - INÍCIO");
    String? storedToken;
    String? storedUserJson;

    try {
      print("[AuthService] tryAutoLogin - Lendo 'authToken' do secureStorage...");
      storedToken = await _secureStorage.read(key: 'authToken');
      print("[AuthService] tryAutoLogin - 'authToken' lido: ${storedToken != null ? 'ENCONTRADO' : 'NULO'}");

      print("[AuthService] tryAutoLogin - Lendo 'userJson' do secureStorage...");
      storedUserJson = await _secureStorage.read(key: 'userJson');
      print("[AuthService] tryAutoLogin - 'userJson' lido: ${storedUserJson != null ? 'ENCONTRADO' : 'NULO'}");

    } catch (e, stackTrace) {
      print("[AuthService] tryAutoLogin - ERRO AO LER DO SECURESTORAGE: $e");
      print("[AuthService] StackTrace do erro no secureStorage: $stackTrace");
      isAuthenticated.value = false;
      print("[AuthService] tryAutoLogin - FIM (devido a erro no storage)");
      return; // Sai do método se houver erro na leitura do storage
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
        // Limpar dados potencialmente corruptos
        try {
          print("[AuthService] tryAutoLogin - Limpando dados (potencialmente corruptos) do storage...");
          await _secureStorage.delete(key: 'authToken');
          await _secureStorage.delete(key: 'userJson');
          print("[AuthService] tryAutoLogin - Dados corruptos limpos.");
        } catch (storageDeleteError, sdelStackTrace) {
          print("[AuthService] tryAutoLogin - ERRO AO LIMPAR dados corruptos do storage: $storageDeleteError");
          print("[AuthService] StackTrace do erro ao limpar storage: $sdelStackTrace");
        }
        isAuthenticated.value = false;
      }
    } else {
      print("[AuthService] tryAutoLogin - Nenhum token ou userJson encontrado para auto-login.");
      isAuthenticated.value = false;
    }
    print("[AuthService] tryAutoLogin - FIM");
  }

  Future<void> loginUserSession(User user, String token) async {
    currentUser.value = user;
    authToken.value = token;
    isAuthenticated.value = true;

    try {
      print("[AuthService] Salvando token no secureStorage...");
      await _secureStorage.write(key: 'authToken', value: token);
      print("[AuthService] Token salvo.");
      print("[AuthService] Salvando userJson no secureStorage...");
      await _secureStorage.write(key: 'userJson', value: jsonEncode(user.toJson()));
      print("[AuthService] userJson salvo.");
    } catch (e, stackTrace) {
      print("[AuthService] ERRO ao salvar no secureStorage em loginUserSession: $e");
      print("[AuthService] StackTrace do erro ao salvar: $stackTrace");
    }
    print("[AuthService] Usuário ${user.email} logado. Token e userJson salvos (ou tentativa).");
  }

  Future<void> logout() async {
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
    Get.offAllNamed(AppRoutes.LOGIN); 
  }

}