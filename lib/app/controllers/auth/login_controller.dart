// lib/app/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/auth/auth_response_model.dart';
import 'package:loot_app/app/data/providers/auth_api_provider.dart'; // Seu provider da API
import 'package:loot_app/app/routes/app_routes.dart';
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
    if (value.length < 6) { // Exemplo de regra de negócio
      return 'A senha deve ter no mínimo 6 caracteres.';
    }
    return null;
  }

  // Método para realizar o login
  Future<void> loginUser() async {
    // Verifica se o formulário é válido
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        AuthResponse? user = await _authApiProvider.login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (user != null) {
          // Sucesso no login!
          // TODO: Salvar o token do usuário (ex: user.rememberToken ou JWT retornado pela API)
          // de forma segura usando um serviço como flutter_secure_storage (via StorageService).
          // Ex: await _storageService.saveToken(apiResponse.token);
          // Ex: await _storageService.saveUserCredentials(user.email, user.id); // Ou dados do usuário

          Get.snackbar(
            'Sucesso!',
            'Login realizado com sucesso. Bem-vindo(a) ${user.firstName}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Navega para a tela principal do app após o login
          // Substitua AppRoutes.HOME pela sua tela principal logada (ex: AppRoutes.DEALS_LIST)
          Get.offAllNamed(AppRoutes.HOME); // Ou a tela principal da sua área logada
        }
        // Se user for null, o _authApiProvider.login já deve ter mostrado um Get.snackbar de erro.
        // Caso contrário, adicione um Get.snackbar de erro genérico aqui.

      } catch (e) {
        Get.snackbar(
          'Erro de Login',
          'Ocorreu um erro inesperado. Tente novamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("Login error: $e"); // Para debug
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Método para navegar para a tela de cadastro
  void navigateToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }
}