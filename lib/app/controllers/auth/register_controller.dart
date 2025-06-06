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
    if (registerFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      bool success = await AuthService.to.registerWithEmail(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
      );
      // Se sucesso, o listener no AuthService já cuidará da navegação
      isLoading.value = false;
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