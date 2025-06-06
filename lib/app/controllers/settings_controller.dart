import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/services/theme_service.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';

class SettingsController extends GetxController {
  final ThemeService _themeService = ThemeService.to;
  final UserPreferencesService _prefsService = UserPreferencesService.to;

  // --- Configurações de Tema ---
  Rx<ThemeMode> get currentThemeSetting => _themeService.currentAppliedThemeMode;
  final List<ThemeMode> themeModes = ThemeMode.values;

  void changeTheme(ThemeMode? newMode) {
    if (newMode != null) {
      _themeService.switchThemeMode(newMode);
      Get.snackbar(
        "Tema Alterado", "O tema do aplicativo foi atualizado.",
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 2),
      );
    }
  }

  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return "Claro";
      case ThemeMode.dark: return "Escuro";
      case ThemeMode.system: default: return "Padrão do Sistema";
    }
  }

  // --- Configurações de Região/País (para GG.deals) ---
  // VVVVVV Alterado de currentCurrencySetting para currentCountrySetting VVVVVV
  RxString get currentCountrySetting => _prefsService.selectedCountryCode;
  // VVVVVV Alterado de availableCurrencies para availableCountries VVVVVV
  List<Map<String, String>> get availableCountries => _prefsService.getSupportedCountriesForGGD();

  // VVVVVV Alterado de changeCurrency para changeCountry VVVVVV
  void changeCountry(String? newCountryCode) {
    if (newCountryCode != null && newCountryCode.isNotEmpty) {
      _prefsService.setSelectedCountryCode(newCountryCode);
      Get.snackbar(
        "Região Alterada", // Mensagem atualizada
        "A região para exibição de preços foi atualizada para ${newCountryCode.toUpperCase()}.", // Mensagem atualizada
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      // A mudança em _prefsService.selectedCountryCode.value
      // será ouvida pelos DealsController e DealDetailController.
    }
  }
}