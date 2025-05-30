import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:loot_app/app/routes/app_pages.dart';
import 'package:loot_app/app/routes/app_routes.dart';
import 'package:loot_app/app/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Loot',
      theme: AppTheme.lightTheme, // Crie seu AppTheme.lightTheme em lib/app/themes/app_theme.dart
      initialRoute: AppRoutes.HOME, // <<<<<< MUDANÇA AQUI
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
