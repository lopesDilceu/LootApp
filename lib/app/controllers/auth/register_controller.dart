// lib/app/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/main_navigation_controller.dart';
import 'package:loot_app/app/data/models/auth/auth_response_model.dart';
import 'package:loot_app/app/data/models/user_model.dart'; // Seu User model
import 'package:loot_app/app/data/providers/auth_api_provider.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';

class RegisterController extends GetxController {
  final AuthApiProvider _authApiProvider = Get.find<AuthApiProvider>();
  // final StorageService _storageService = Get.find<StorageService>(); // Se for salvar token aqui

  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleObscurePassword() => obscurePassword.value = !obscurePassword.value;
  void toggleObscureConfirmPassword() => obscureConfirmPassword.value = !obscureConfirmPassword.value;

  // --- Validadores ---
  String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'O campo $fieldName é obrigatório.';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'O campo Email é obrigatório.';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Por favor, insira um email válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Senha é obrigatório.';
    }
    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres.';
    }
    // Você pode adicionar mais regras aqui (ex: maiúsculas, números, símbolos)
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo Confirmar Senha é obrigatório.';
    }
    if (value != passwordController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }
  // --- Fim Validadores ---

  Future<void> registerUser() async {
    if (registerFormKey.currentState!.validate()) {
      isLoading.value = true;
      print("[RegisterController] Formulário validado. Chamando _authApiProvider.register().");
      try {
        AuthResponse? authResponse = await _authApiProvider.register(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          role: Role.user, // Ou conforme sua lógica
        );

        print("[RegisterController] authResponse recebido do provider: ${authResponse == null ? 'NULO' : 'RECEBIDO'}");

        if (authResponse != null) {
          print("[RegisterController] Cadastro BEM-SUCEDIDO via provider. Chamando AuthService.to.loginUserSession().");
          // VVVVVV ESTA É A CHAMADA CRUCIAL VVVVVV
          await AuthService.to.loginUserSession(authResponse.user, authResponse.token);
          // VVVVVV FIM DA CHAMADA CRUCIAL VVVVVV
          print("[RegisterController] AuthService.to.loginUserSession() CONCLUÍDO.");

          Get.snackbar(
            'Cadastro Realizado!',
            'Bem-vindo(a) ao LooT, ${authResponse.user.firstName}! Você já está conectado(a).',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          // Navega para a tela principal LOGADA (ex: DealsListScreen)
          Get.offAllNamed(AppRoutes.MAIN_NAVIGATION, arguments: {'initialTabIndex': 1});
        } else {
          print("[RegisterController] Cadastro FALHOU: _authApiProvider.register() retornou null.");
          // O AuthApiProvider já deve ter mostrado um Snackbar de erro.
        }
      } catch (e, stackTrace) {
        print("[RegisterController] EXCEÇÃO ao chamar _authApiProvider.register() ou AuthService: $e");
        print("[RegisterController] StackTrace da exceção: $stackTrace");
        Get.snackbar('Erro no Cadastro', 'Ocorreu um erro inesperado. Tente novamente.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }

  void navigateToLoginPage() {
    print("[RegisterController] Navegando para LoginPageContent via MainNavigationController.");
    if (Get.isRegistered<MainNavigationController>()) {
      MainNavigationController.to.navigateToLoginPage();
    } else {
      print("[RegisterController] ERRO: MainNavigationController não encontrado.");
    }
  }
}