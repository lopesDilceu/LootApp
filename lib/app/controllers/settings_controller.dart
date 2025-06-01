import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/services/theme_service.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = ThemeService.to;
  final UserPreferencesService _userPreferencesService = UserPreferencesService.to;

  // --- Configurações de Tema ---
  // selectedThemeMode agora é uma referência direta à propriedade reativa do ThemeService
  Rx<ThemeMode> get currentThemeSetting => _themeService.currentAppliedThemeMode;
  
  final List<ThemeMode> themeModes = ThemeMode.values; // [system, light, dark]

  void changeTheme(ThemeMode? newMode) {
    if (newMode != null) {
      _themeService.switchThemeMode(newMode); // O ThemeService já atualiza o currentAppliedThemeMode
      // O Get.snackbar pode ser movido para o switchThemeMode no ThemeService se preferir
      Get.snackbar(
        "Tema Alterado",
        "O tema do aplicativo foi atualizado.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Claro";
      case ThemeMode.dark:
        return "Escuro";
      case ThemeMode.system:
      return "Padrão do Sistema";
    }
  }

  // --- Configurações de Moeda ---
  // selectedCountryCode agora é uma referência direta à propriedade reativa do UserPreferencesService
  RxString get currentCountrySetting => _userPreferencesService.selectedCountryCode;

  List<Map<String, String>> get availableCurrencies => _userPreferencesService.getSupportedCountries();

  void changeCountry(String? newCountryCode) {
    if (newCountryCode != null && newCountryCode.isNotEmpty) {
      _userPreferencesService.setSelectedCountryCode(newCountryCode);
      // O snackbar pode ser movido para setSelectedCountry no UserPreferencesService
      Get.snackbar(
        "Moeda Alterada",
        "A moeda para exibição de preços foi atualizada para $newCountryCode.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      // AVISO: Você pode precisar de uma forma de notificar outras partes do app
      // (como listas de deals) para recarregar/reconverter os preços.
      // Isso pode ser feito com um Get.forceAppUpdate(), ou fazendo seus controllers de deals
      // ouvirem mudanças em UserPreferencesService.selectedCountry.
    }
  }
}