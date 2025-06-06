// lib/app/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/data/models/auth/auth_response_model.dart';
import 'package:loot_app/app/data/providers/auth_api_provider.dart'; // Seu provider da API
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
// Importe seu serviço de storage se for salvar tokens/dados do usuário
// import 'package:loot_app/app/services/storage_service.dart';

class LoginController extends GetxController {
  // Injeta o AuthApiProvider (deve estar registrado no AuthBinding ou globalmente)
  final AuthApiProvider _authApiProvider = Get.find<AuthApiProvider>();
  // final StorageService _storageService = Get.find<StorageService>(); // Exemplo

  // Chave para o formulário, para validações
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variáveis reativas para o estado da UI
  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs; // Para mostrar/ocultar senha

  @override
  void onClose() {
    // Limpa os controllers quando o LoginController é fechado para evitar memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Método para alternar a visibilidade da senha
  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Validador para o campo de email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email.';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Por favor, insira um email válido.';
    }
    return null;
  }

  // Validador para o campo de senha
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha.';
    }
    if (value.length < 6) {
      // Exemplo de regra de negócio
      return 'A senha deve ter no mínimo 6 caracteres.';
    }
    return null;
  }

  // Método para realizar o login
    Future<void> loginUser() async {
    if (loginFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      bool success = await AuthService.to.loginWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      // Se sucesso, o listener no AuthService já cuidará da navegação
      // Se não, o AuthService já mostrou um snackbar de erro
      isLoading.value = false;
    }
  }

    void navigateToRegisterPage() { // << MÉTODO ADICIONADO/CORRIGIDO
    print("[LoginController] Navegando para RegisterPageContent via MainNavigationController.");
    if (Get.isRegistered<MainNavigationController>()) {
      MainNavigationController.to.navigateToRegisterPage();
    } else {
      print("[LoginController] ERRO: MainNavigationController não encontrado.");
    }
  }

}
