// lib/app/controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/user_model.dart'; // Seu User model
import 'package:loot_app/app/data/providers/auth_api_provider.dart';
import 'package:loot_app/app/routes/app_routes.dart';

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
      try {
        // O Role.user é assumido aqui, ajuste se necessário ou se vier do formulário
        User? user = await _authApiProvider.register(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text, // Senha não deve ter trim() extra se espaços forem permitidos
          role: Role.user, // Ou como sua API espera/define o role
        );

        if (user != null) {
          // Sucesso no cadastro!
          // TODO: Salvar o token do usuário (user.rememberToken ou o JWT retornado pela API)
          // da mesma forma que no login, para que o usuário já fique logado.
          // Ex: await _storageService.saveToken(apiResponse.token); // se register retorna token
          // Ex: await _storageService.saveUserCredentials(user.email, user.id);

          Get.snackbar(
            'Cadastro Realizado!',
            'Sua conta foi criada com sucesso, ${user.firstName}! Você já pode fazer login ou será redirecionado.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          // Opção 1: Navegar para a tela de login para o usuário entrar
          Get.offAllNamed(AppRoutes.LOGIN);
          // Opção 2: Se o backend já retorna um token e loga o usuário, navegar para a tela principal
          // Get.offAllNamed(AppRoutes.HOME); // Ou sua rota principal logada
        }
        // Se user for null, o _authApiProvider.register já deve ter mostrado um Snackbar de erro.

      } catch (e) {
        Get.snackbar(
          'Erro no Cadastro',
          'Ocorreu um erro inesperado. Tente novamente.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("RegisterUser Exception: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }
}