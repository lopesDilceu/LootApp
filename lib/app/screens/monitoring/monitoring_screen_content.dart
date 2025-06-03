import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/monitoring_controller.dart';

class MonitoringScreenContent extends GetView<MonitoringController> {
  const MonitoringScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    print("[MonitoringScreenContent] build.");
    // O controller é injetado pelo GetView, e o MainNavigationBinding
    // já deve ter registrado o MonitoringController com fenix:true.
    return Obx(() { // Exemplo se houver um isLoading no controller
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Meus Jogos Monitorados\n(Funcionalidade em Desenvolvimento)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      );
    });
  }
}