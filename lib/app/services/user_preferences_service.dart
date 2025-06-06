import 'package:flutter/material.dart'; // Para Locale
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loot_app/app/controllers/deal_detail_controller.dart';
import 'package:loot_app/app/controllers/deals_controller.dart';

class UserPreferencesService extends GetxService {
  static UserPreferencesService get to => Get.find();
  final _box = GetStorage();
  final String _countryKey = 'user_selected_country_code_ggd'; // Chave específica
  late RxString selectedCountryCode;

  @override
  void onInit() {
    super.onInit();
    selectedCountryCode = ((_box.read(_countryKey) ?? _defaultCountryCode()) as String).obs;

    print("[UserPreferencesService] País (para GG.deals) inicializado: ${selectedCountryCode.value}");
  }

  String _defaultCountryCode() {
    Locale? deviceLocale = Get.deviceLocale;
    // A API da GG.deals usa códigos de país em minúsculas (ex: 'us', 'br')
    return deviceLocale?.countryCode?.toLowerCase() ?? 'us'; 
  }

  void setSelectedCountryCode(String countryCode) {
    final newCode = countryCode.toLowerCase(); // GG.deals geralmente espera minúsculas
    if (selectedCountryCode.value == newCode) return;

    _box.write(_countryKey, newCode);
    selectedCountryCode.value = newCode;
    print("[UserPreferencesService] País (para GG.deals) definido para: ${selectedCountryCode.value}");
    
    // Dispara a atualização dos dados que dependem do país
    // Ex: Se DealsController estiver ouvindo, ele deve recarregar
    // if (Get.isRegistered<DealsController>()) {
    //    Get.find<DealsController>().countryOrFiltersChanged();
    // }
    // if (Get.isRegistered<DealDetailController>()) {
    //   // O DealDetailController já ouve e reage no seu onInit ou loadDealDetails
    // }
  }

  List<Map<String, String>> getSupportedCountriesForGGD() {
    return [
      {'code': 'us', 'name': 'Estados Unidos'},
      {'code': 'br', 'name': 'Brasil'},
      {'code': 'de', 'name': 'Alemanha (Europa 1)'}, // Exemplo, pode ser 'eu1'
      {'code': 'gb', 'name': 'Reino Unido'},
      // Adicione mais conforme a documentação da GG.deals
    ];
  }

    // Helper para obter o símbolo da moeda
  String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'BRL': return 'R\$';
      case 'EUR': return '€';
      case 'USD': default: return '\$';
    }
  }

  // Helper para obter o locale para formatação
  String getLocaleForCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'BRL': return 'pt_BR';
      case 'EUR': return 'de_DE'; // Formato Euro comum, pode ser 'fr_FR', 'es_ES', etc.
      case 'USD': default: return 'en_US';
    }
  }
}
