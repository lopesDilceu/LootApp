// lib/app/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/auth/login_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O controller é injetado automaticamente pelo GetView através do AuthBinding
    return Scaffold(
      appBar: const CommonAppBar(title: 'Login - Loot'),
      body: SingleChildScrollView(
        // Permite rolagem se o conteúdo for maior que a tela
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: controller.loginFormKey, // Associa a chave do formulário
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, // Estica os botões
            children: <Widget>[
              SvgPicture.asset(
                'images/logos/logo-binoculars-text-light.svg',
                width: 128,
                height: 128,
                colorFilter: null,
                semanticsLabel: 'Logo Loot App',
              ),
              const SizedBox(height: 30),
              Text(
                'Acesse sua Conta',
                textAlign: TextAlign.center,
                style: Get.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: controller.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'seuemail@exemplo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
                autovalidateMode: AutovalidateMode
                    .onUserInteraction, // Valida enquanto o usuário digita
              ),
              const SizedBox(height: 20),
              // Obx para reconstruir o widget quando obscurePassword mudar
              Obx(
                () => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Sua senha',
                    prefixIcon: const Icon(Icons.lock_outline_sharp),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: controller.toggleObscurePassword,
                    ),
                  ),
                  obscureText: controller.obscurePassword.value,
                  validator: controller.validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implementar lógica de "Esqueci minha senha"
                    Get.snackbar(
                      'Oops!',
                      'Funcionalidade "Esqueci minha senha" em breve!',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: const Text('Esqueceu a senha?'),
                ),
              ),
              const SizedBox(height: 25),
              // Obx para mostrar o indicador de carregamento ou o botão
              Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: controller.loginUser,
                        child: const Text('Entrar'),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem uma conta?'),
                  TextButton(
                    onPressed: controller.navigateToRegister,
                    child: Text(
                      'Cadastre-se',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
