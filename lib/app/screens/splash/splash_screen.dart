import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("[SplashScreen] build() chamado.");
     try {
      print("[SplashScreen] Tentando Get.find<SplashController>() explicitamente...");
      final c = Get.find<SplashController>(); // Tenta encontrar/criar
      print("[SplashScreen] Get.find<SplashController>() bem-sucedido! Controller Hash: ${c.hashCode}");
    } catch (e, stackTrace) {
      print("[SplashScreen] ERRO no Get.find<SplashController>(): $e");
      print("[SplashScreen] StackTrace do erro no Get.find: $stackTrace");
    }
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Carregando Loot...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}