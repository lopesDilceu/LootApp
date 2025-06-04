import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loot_app/app/controllers/profile_controller.dart';

class ProfileScreenContent extends GetView<ProfileController> {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    print("[ProfilePageContent] build. User: ${controller.user?.email}");
    return Obx(() {
      if (controller.user == null) {
        return const Center(child: Text("Usuário não encontrado ou não logado."));
      }
      return SingleChildScrollView(
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
            Text("Membro desde: ${DateFormat('dd/MM/yyyy').format(controller.user!.createdAt.toLocal())}", style: Get.textTheme.bodyMedium),
          ],
        ),
      );
    });
  }
}