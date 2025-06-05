import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // Para SvgPicture
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/auth/login_controller.dart'; // Usa LoginController

class LoginScreenContent extends GetView<LoginController> { 
  const LoginScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: controller.loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset( // Exemplo de logo, ajuste o caminho e cor
              'assets/images/logos/logo-binoculars-text-light.svg', 
              width: 128, height: 128,
              // colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn), // Para tingir com cor do tema
            ),
            const SizedBox(height: 30),
            Text(
              'Acesse sua Conta',
              textAlign: TextAlign.center,
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                // color: Theme.of(context).primaryColorDark, // Use colorScheme
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'seuemail@exemplo.com',
                prefixIcon: Icon(Icons.email_outlined),
                // border: OutlineInputBorder(), // Definido no tema global
              ),
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 20),
            Obx(() => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Sua senha',
                    prefixIcon: const Icon(Icons.lock_outline_sharp),
                    // border: const OutlineInputBorder(), // Definido no tema global
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscurePassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: controller.toggleObscurePassword,
                    ),
                  ),
                  obscureText: controller.obscurePassword.value,
                  validator: controller.validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                )),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Get.snackbar('Oops!', 'Funcionalidade "Esqueci minha senha" em breve!', snackPosition: SnackPosition.BOTTOM);
                },
                child: const Text('Esqueceu a senha?'),
              ),
            ),
            const SizedBox(height: 25),
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: controller.loginUser,
                    child: const Text('Entrar'),
                  )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Não tem uma conta?'),
                TextButton(
                  onPressed: controller.navigateToRegisterPage, // <<< CHAMADA CORRIGIDA
                  child: Text(
                    'Cadastre-se',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary), // Usa cor do tema
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
