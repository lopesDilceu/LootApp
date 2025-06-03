import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/settings_controller.dart';

class SettingsScreenContent extends GetView<SettingsController> {
  const SettingsScreenContent({super.key});

@override
  Widget build(BuildContext context) {
    print("[SettingsPageContent] build.");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Tema do Aplicativo", style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<ThemeMode>(
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15)),
                value: controller.currentThemeSetting.value,
                items: controller.themeModes.map((ThemeMode mode) {
                  return DropdownMenuItem<ThemeMode>(value: mode, child: Text(controller.getThemeModeDisplayName(mode)));
                }).toList(),
                onChanged: controller.changeTheme,
              )),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text("Moeda para Preços", style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15)),
                value: controller.currentCurrencySetting.value,
                items: controller.availableCurrencies.map((Map<String, String> currency) {
                  return DropdownMenuItem<String>(value: currency['code'], child: Text(currency['name']!));
                }).toList(),
                onChanged: controller.changeCurrency,
              )),
        ],
      ),
    );
  }
}
