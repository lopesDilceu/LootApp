import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loot_app/app/services/user_preferences_service.dart';

class CurrencyService extends GetxService {
  static CurrencyService get to => Get.find();

  // SUBSTITUA PELA SUA API KEY DA EXCHANGERATE-API.COM
  final String _apiKey = '94d1ac5c5f7ea44614d3e28b'; 
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6/';

  // Cache para as taxas de câmbio em relação ao USD
  final RxMap<String, double> exchangeRatesFromUSD = <String, double>{}.obs;
  final Rxn<DateTime> lastFetchTime = Rxn<DateTime>();
  final RxBool isLoadingRates = false.obs;
  final RxBool ratesInitialized = false.obs; // Para saber se a carga inicial ocorreu

  // Método para ser chamado na inicialização do app
  Future<CurrencyService> initService() async {
    print("[CurrencyService] Iniciando e buscando taxas de câmbio iniciais...");
    await fetchExchangeRatesIfNeeded(); // Busca ao iniciar
    ratesInitialized.value = true;
    print("[CurrencyService] Serviço inicializado. Taxas carregadas: ${exchangeRatesFromUSD.isNotEmpty}");
    return this;
  }

  Future<void> fetchExchangeRatesIfNeeded({bool force = false}) async {
    // Cache simples: busca apenas se não tiver dados ou se os dados tiverem mais de 1 hora
    if (!force &&
        exchangeRatesFromUSD.isNotEmpty &&
        lastFetchTime.value != null &&
        DateTime.now().difference(lastFetchTime.value!).inHours < 1) {
      print("[CurrencyService] Usando taxas de câmbio do cache.");
      return;
    }

    if (isLoadingRates.value) return; // Evita chamadas múltiplas

    isLoadingRates.value = true;
    print("[CurrencyService] Buscando novas taxas de câmbio para USD...");
    final String url = '$_baseUrl$_apiKey/latest/USD';

    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success' && data['conversion_rates'] != null) {
          final rates = data['conversion_rates'] as Map<String, dynamic>;
          
          // Limpa o mapa antes de adicionar novas taxas para evitar duplicatas se as chaves mudarem
          final newRates = <String, double>{};
          rates.forEach((key, value) {
            newRates[key.toUpperCase()] = (value as num).toDouble();
          });
          exchangeRatesFromUSD.assignAll(newRates); // Atualiza o RxMap de forma reativa

          lastFetchTime.value = DateTime.now();
          print("[CurrencyService] Taxas de câmbio atualizadas. ${exchangeRatesFromUSD.length} taxas carregadas.");
        } else {
          print("[CurrencyService] Erro nos dados da API de câmbio: ${data['error-type'] ?? 'Erro desconhecido'}");
          // Get.snackbar("Erro de Câmbio", "Não foi possível obter as taxas: ${data['error-type']}");
        }
      } else {
        print("[CurrencyService] Erro ao buscar taxas de câmbio: ${response.statusCode}");
        // Get.snackbar("Erro de API", "Falha ao buscar taxas de câmbio: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("[CurrencyService] Exceção ao buscar taxas de câmbio: $e");
      print(stackTrace);
      // Get.snackbar("Erro de Rede", "Exceção ao buscar taxas de câmbio.");
    } finally {
      isLoadingRates.value = false;
    }
  }

  // Obtém a taxa de USD para uma moeda específica do cache
  double? _getRateFromUSDTo(String targetCurrency) {
    return exchangeRatesFromUSD[targetCurrency.toUpperCase()];
  }


  // Converte um valor de USD para a moeda alvo
  double? convertFromUSD(double usdAmount, String targetCurrency) {
    if (targetCurrency.toUpperCase() == 'USD') return usdAmount;
    final rate = _getRateFromUSDTo(targetCurrency);
    if (rate != null) {
      return usdAmount * rate;
    }
    return null; // Retorna null se a taxa não estiver disponível
  }

  String getFormattedPrice(double usdAmount, {String? forceCurrencyCode}) {
    final prefsService = UserPreferencesService.to;
    
    String targetCurrencyCode = (forceCurrencyCode ?? prefsService.selectedCurrency.value).toUpperCase();
    
    String displaySymbol = prefsService.getCurrencySymbol(targetCurrencyCode);
    String displayLocale = prefsService.getLocaleForCurrency(targetCurrencyCode);

    // Se for USD ou se as taxas não estiverem prontas (e não for USD), mostra em USD
    if (targetCurrencyCode == 'USD' || (!ratesInitialized.value && targetCurrencyCode != 'USD')) {
      return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(usdAmount);
    }

    // Para outras moedas, tenta converter
    double? rate = _getRateFromUSDTo(targetCurrencyCode);
    if (rate != null) {
      double convertedPrice = usdAmount * rate;
      return NumberFormat.currency(
        locale: displayLocale,
        symbol: displaySymbol,
        decimalDigits: 2,
      ).format(convertedPrice);
    } else {
      // Fallback se a taxa específica não estiver disponível, mas as taxas gerais foram inicializadas
      // Isso pode acontecer se a API de câmbio não retornar a taxa para uma moeda específica que você suporta
      print("[CurrencyService] Taxa não encontrada para $targetCurrencyCode. Exibindo em USD.");
      return "${NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(usdAmount)} (USD)";
    }
  }
}