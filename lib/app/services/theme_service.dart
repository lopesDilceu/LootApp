import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  final _getStorage = GetStorage();
  final _themeModeKey = 'app_theme_mode';

  // Variável Reativa para o ThemeMode atualmente aplicado
  // Será inicializada no método initTheme()
  late Rx<ThemeMode> currentAppliedThemeMode;

  // Este getter lê a preferência salva, usado para inicialização
  ThemeMode get _preferredThemeMode {
    final String? themeString = _getStorage.read(_themeModeKey);
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default: // Inclui null ou 'system'
        return ThemeMode.system;
    }
  }

  Future<void> _saveThemeModePreference(ThemeMode mode) async {
    await _getStorage.write(_themeModeKey, mode.name);
  }

  void switchThemeMode(ThemeMode newMode) {
    Get.changeThemeMode(newMode);       // Informa ao GetMaterialApp para mudar
    currentAppliedThemeMode.value = newMode; // Atualiza nossa variável reativa
    _saveThemeModePreference(newMode);
    print("[ThemeService] Tema alterado para: ${newMode.name}");
  }

  // Chamado no main.dart após Get.put(ThemeService())
  void initTheme() {
    final preferredMode = _preferredThemeMode;
    currentAppliedThemeMode = preferredMode.obs; // Inicializa a variável Rx com o valor salvo/padrão
    Get.changeThemeMode(preferredMode); // Aplica o tema inicial ao GetMaterialApp
    print("[ThemeService] Tema inicial carregado e aplicado: ${preferredMode.name}");
  }
}