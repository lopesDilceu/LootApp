import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/profile_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart'; // Seu AppBar comum

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Meu Perfil"),
      body: Obx(() { // Obx para reagir a mudanças no usuário se ProfileController o tornar reativo
        if (controller.user == null) {
          return const Center(child: Text("Usuário não encontrado ou não logado."));
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nome: ${controller.user!.firstName} ${controller.user!.lastName}", style: Get.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text("Email: ${controller.user!.email}", style: Get.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text("Role: ${controller.user!.role.name}", style: Get.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text("Membro desde: ${controller.user!.createdAt.toLocal().toString().substring(0,10)}", style: Get.textTheme.bodyMedium), // Formato simples de data
              // Adicione mais informações ou opções de edição aqui
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () { /* Lógica para editar perfil */ },
              //   child: const Text("Editar Perfil (Em breve)"),
              // ),
            ],
          ),
        );
      }),
    );
  }
}