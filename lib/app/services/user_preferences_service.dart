import 'package:flutter/material.dart'; // Para Locale
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserPreferencesService extends GetxService {
  static UserPreferencesService get to => Get.find();
  final _box = GetStorage();

  final String _currencyKey = 'user_selected_currency';

  late RxString selectedCurrency; // Mantém como late RxString

  @override
  void onInit() {
    super.onInit();
    print("[UserPreferencesService] onInit - INÍCIO");
    // Passo 1: Obtenha o valor da string
    String initialCurrencyValue = _box.read(_currencyKey) ?? _defaultCurrency;
    print("[UserPreferencesService] Valor inicial da moeda lido/padrão: $initialCurrencyValue");

    // Passo 2: Crie o RxString com este valor
    selectedCurrency = RxString(initialCurrencyValue); 
    // OU, para ser explícito com GetX e garantir que a reatividade seja registrada corretamente:
    // selectedCurrency = initialCurrencyValue.obs; // Se esta linha ainda der erro, a abaixo é mais segura:
    // selectedCurrency = Get.rx(initialCurrencyValue); // Outra forma de criar um Rx<String>

    print("[UserPreferencesService] Moeda inicializada: ${selectedCurrency.value}");
    print("[UserPreferencesService] onInit - FIM");
  }

  String get _defaultCurrency {
    // ... (seu método _defaultCurrency como antes)
    Locale? deviceLocale = Get.deviceLocale;
    String defaultCurrencyValue = 'USD'; // Padrão fallback
    if (deviceLocale != null) {
      if (deviceLocale.countryCode == 'BR') defaultCurrencyValue = 'BRL';
      else if (deviceLocale.countryCode == 'US') defaultCurrencyValue = 'USD';
      // ... (lógica para euroZoneCountries)
      else {
         List<String> euroZoneCountries = ['DE', 'FR', 'IT', 'ES', 'PT', 'NL', 'BE', 'AT', 'FI', 'GR', 'IE', 'CY', 'EE', 'LV', 'LT', 'LU', 'MT', 'SK', 'SI'];
         if (euroZoneCountries.contains(deviceLocale.countryCode?.toUpperCase())) defaultCurrencyValue = 'EUR';
      }
    }
    print("[UserPreferencesService] _defaultCurrency calculado: $defaultCurrencyValue");
    return defaultCurrencyValue;
  }

  void setSelectedCurrency(String currencyCode) {
    _box.write(_currencyKey, currencyCode);
    selectedCurrency.value = currencyCode;
    print("[UserPreferencesService] Moeda definida para: $currencyCode");
  }

  List<Map<String, String>> getSupportedCurrencies() {
    return [
      {'code': 'USD', 'name': 'Dólar Americano (\$ USD)'},
      {'code': 'BRL', 'name': 'Real Brasileiro (R\$ BRL)'},
      {'code': 'EUR', 'name': 'Euro (€ EUR)'},
    ];
  }
}