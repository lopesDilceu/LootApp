import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/settings_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart'; // Sua CommonAppBar

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: "Configurações"), // Passa o título
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Tema do Aplicativo",
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => DropdownButtonFormField<ThemeMode>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),
                value: controller.currentThemeSetting.value,
                items: controller.themeModes.map((ThemeMode mode) {
                  return DropdownMenuItem<ThemeMode>(
                    value: mode,
                    child: Text(controller.getThemeModeDisplayName(mode)),
                  );
                }).toList(),
                onChanged: (ThemeMode? newValue) {
                  controller.changeTheme(newValue);
                },
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            // Text(
            //   "Moeda para Preços",
            //   style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // Obx(() => DropdownButtonFormField<String>(
            //       decoration: const InputDecoration(
            //         border: OutlineInputBorder(),
            //         contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            //       ),
            //       value: controller.currentCurrencySetting.value,
            //       items: controller.availableCurrencies.map((Map<String, String> currency) {
            //         return DropdownMenuItem<String>(
            //           value: currency['code'],
            //           child: Text(currency['name']!),
            //         );
            //       }).toList(),
            //       onChanged: (String? newValue) {
            //         controller.changeCurrency(newValue);
            //       },
            //     )),
            // const SizedBox(height: 20),
            // Você pode adicionar mais configurações aqui no futuro
          ],
        ),
      ),
    );
  }
}
