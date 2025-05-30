import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart'; // Importe
// ... outros imports (controller, etc.)
class DealsListScreen extends GetView<DealsController> { // Supondo um DealsController
  const DealsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Promoções Quentes!',
        showBackButton: false, // A tela principal logada geralmente não tem voltar
      ),
      body: const Center(child: Text("Lista de Promoções!")), // Conteúdo da tela
    );
  }
}