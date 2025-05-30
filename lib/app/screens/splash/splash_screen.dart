import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // controller é injetado automaticamente
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Substitua pelo seu logo ou uma animação Lottie
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Carregando Loot...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
