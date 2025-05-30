import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/routes/app_pages.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/services/auth/auth_service.dart'; // Importe
import 'package:loot_app/app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeServices(); // Função para inicializar serviços
  runApp(const MyApp());
}

Future<void> initializeServices() async {
  print("Inicializando serviços...");
  await Get.putAsync(() => AuthService().onInit()); // Chama onInit do AuthService
  // Coloque outros Get.put para serviços globais aqui, se necessário
  // Ex: Get.put(ApiProvider(), permanent: true);
  print("Serviços inicializados.");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loot',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.SPLASH, // << ROTA INICIAL É A SPLASH
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}