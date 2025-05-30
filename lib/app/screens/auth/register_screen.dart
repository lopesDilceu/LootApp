// lib/app/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/auth/register_controller.dart'; // Importe o controller

class RegisterScreen extends GetView<RegisterController> { // Use GetView
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O controller é injetado pelo AuthBinding
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro - Loot')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Tela de Cadastro (em construção)',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                // Exemplo de como chamar um método do controller
                onPressed: controller.registerUser, // Método placeholder
                child: const Text('Cadastrar (Teste)'),
              )
            ],
          ),
        ),
      ),
    );
  }
}