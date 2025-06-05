import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/auth/register_controller.dart'; // Usa RegisterController

class RegisterScreenContent extends GetView<RegisterController> { 
  const RegisterScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: controller.registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SvgPicture.asset( 
              'assets/images/logos/logo-binoculars-text-light.svg', // Use 'assets/' para mobile
              width: 100, height: 100,
              // colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn),
            ),
            const SizedBox(height: 20),
            Text(
              'Crie sua Conta',
              textAlign: TextAlign.center,
              style: Get.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: controller.firstNameController,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)),
              validator: (value) => controller.validateNotEmpty(value, 'Nome'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller.lastNameController,
              decoration: const InputDecoration(labelText: 'Sobrenome', prefixIcon: Icon(Icons.person_outline)),
              validator: (value) => controller.validateNotEmpty(value, 'Sobrenome'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
              keyboardType: TextInputType.emailAddress,
              validator: controller.validateEmail,
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
            const SizedBox(height: 20),
            Obx(() => TextFormField(
                  controller: controller.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Senha (mín. 6 caracteres)',
                    prefixIcon: const Icon(Icons.lock_outline_sharp),
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscurePassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: controller.toggleObscurePassword,
                    ),
                  ),
                  obscureText: controller.obscurePassword.value,
                  validator: controller.validatePassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                )),
            const SizedBox(height: 20),
             Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: const Icon(Icons.lock_outline_sharp),
                    suffixIcon: IconButton(
                      icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: controller.toggleObscureConfirmPassword,
                    ),
                  ),
                  obscureText: controller.obscureConfirmPassword.value,
                  validator: controller.validateConfirmPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                )),
            const SizedBox(height: 30),
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: controller.registerUser,
                    child: const Text('Cadastrar'),
                  )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Já tem uma conta?'),
                TextButton(
                  onPressed: controller.navigateToLoginPage,
                  child: Text(
                    'Faça Login',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
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