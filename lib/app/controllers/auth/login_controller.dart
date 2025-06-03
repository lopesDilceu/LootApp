// lib/app/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true;
      print(
        "[LoginController] Formulário validado. Chamando _authApiProvider.login().",
      );
      try {
        // _authApiProvider.login() agora retorna AuthResponse?
        AuthResponse? authResponse = await _authApiProvider.login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        print(
          "[LoginController] authResponse recebido do provider: ${authResponse == null ? 'NULO' : 'RECEBIDO'}",
        );

        if (authResponse != null) {
          print(
            "[LoginController] Login BEM-SUCEDIDO via provider. Chamando AuthService.to.loginUserSession().",
          );
          // VVVVVV ESTA É A CHAMADA CRUCIAL VVVVVV
          await AuthService.to.loginUserSession(
            authResponse.user,
            authResponse.token,
          );
          // VVVVVV FIM DA CHAMADA CRUCIAL VVVVVV
          print(
            "[LoginController] AuthService.to.loginUserSession() CONCLUÍDO.",
          );

          Get.snackbar(
            'Sucesso!',
            'Login realizado com sucesso. Bem-vindo(a) ${authResponse.user.firstName}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          // Navega para a tela principal LOGADA (ex: DealsListScreen)
          Get.offAllNamed(AppRoutes.MAIN_NAVIGATION, arguments: {'initialTabIndex': 1});
        } else {
          print(
            "[LoginController] Login FALHOU: _authApiProvider.login() retornou null.",
          );
          // O AuthApiProvider já deve ter mostrado um Snackbar de erro se authResponse for null.
        }
      } catch (e, stackTrace) {
        print(
          "[LoginController] EXCEÇÃO ao chamar _authApiProvider.login() ou AuthService: $e",
        );
        print("[LoginController] StackTrace da exceção: $stackTrace");
        Get.snackbar(
          'Erro de Login',
          'Ocorreu um erro: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
      print("[LoginController] Formulário INVÁLIDO.");
    }
  }

  // Método para navegar para a tela de cadastro
  void navigateToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }
}
