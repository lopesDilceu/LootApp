import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:loot_app/app/services/currency_service.dart';

class UserPreferencesService extends GetxService {
  static UserPreferencesService get to => Get.find();
  final _box = GetStorage();

  final String _countryKey = 'user_selected_country_code';
  late RxString selectedCountryCode; // Ex: "BR", "US", "DE"

  @override
  void onInit() {
    super.onInit();
    print("[UserPreferencesService] onInit - INÍCIO");
    // Passo 1: Obtenha o valor da string
    String initialCountryCode = _box.read(_countryKey) ?? _defaultCountryCode;
    print(
      "[UserPreferencesService] Valor inicial da moeda lido/padrão: $initialCountryCode",
    );

    // Passo 2: Crie o RxString com este valor
    selectedCountryCode = RxString(initialCountryCode);
    // OU, para ser explícito com GetX e garantir que a reatividade seja registrada corretamente:
    // selectedCurrency = initialCountryCode.obs; // Se esta linha ainda der erro, a abaixo é mais segura:
    // selectedCurrency = Get.rx(initialCountryCode); // Outra forma de criar um Rx<String>

    print(
      "[UserPreferencesService] Moeda inicializada: ${selectedCountryCode.value}",
    );
    print("[UserPreferencesService] onInit - FIM");
  }

  String get _defaultCountryCode {
    Locale? deviceLocale = Get.deviceLocale;
    // Retorna o código do país do dispositivo se disponível, senão USD (EUA)
    return deviceLocale?.countryCode?.toUpperCase() ?? 'US';
  }

  void setSelectedCountryCode(String countryCode) {
    final newCode = countryCode.toUpperCase();
    if (selectedCountryCode.value == newCode) return; // Evita processamento desnecessário se não mudou

    _box.write(_countryKey, newCode);
    selectedCountryCode.value = newCode; // Esta atualização DISPARARÁ os listeners (ex: no DealsController)
    print("[UserPreferencesService] País definido para: ${selectedCountryCode.value}");

    // A chamada abaixo para CurrencyService é opcional e depende se você ainda usa
    // o CurrencyService para conversão direta como fallback principal.
    // Se o foco agora é GG.deals, o DealsController que deve reagir.
    // Se ainda quiser atualizar as taxas do CurrencyService:
    // if (Get.isRegistered<CurrencyService>()) {
    //   CurrencyService.to.fetchExchangeRatesIfNeeded(force: true);
    // }
  }

  // Países suportados para seleção (e para a API da GG.deals)
  List<Map<String, String>> getSupportedCountries() {
    return [
      {'code': 'US', 'name': 'Estados Unidos (USD)'},
      {'code': 'BR', 'name': 'Brasil (BRL)'},
      {'code': 'DE', 'name': 'Alemanha (EUR)'},
      {'code': 'GB', 'name': 'Reino Unido (GBP)'},
      // Adicione mais países/regiões que a GG.deals suporta e que são relevantes
    ];
  }

  // Helpers para símbolo/locale podem ainda ser úteis se GG.deals não retornar símbolo
  // ou se você precisar formatar um preço numérico que ela retorne.
  // A GG.deals geralmente retorna 'price_formatted' e 'currency_formatted'.
   String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'BRL': return 'R\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'USD': default: return '\$';
    }
  }

  String getLocaleForCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'BRL': return 'pt_BR';
      case 'EUR': return 'de_DE'; 
      case 'GBP': return 'en_GB';
      case 'USD': default: return 'en_US';
    }
  }
}