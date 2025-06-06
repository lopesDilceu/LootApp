// lib/app/shared/constants/api_constants.dart
// (Anteriormente loot_app/app/constants/api/api_constants.dart, ajuste o caminho se necessário)
import 'dart:io' show Platform; // Para verificar a plataforma
import 'package:flutter/foundation.dart' show kIsWeb; // Para verificar se é web

class ApiConstants {
  // --- MUDANÇA PRINCIPAL AQUI ---

  // URL base para o backend em produção (na Railway)
  static const String _prodBaseUrl = "https://users-backend-api-production.up.railway.app";
  
  // URL base para desenvolvimento LOCAL
  // Usa 10.0.2.2 para o emulador Android e localhost para outras plataformas (web, desktop)
  // static final String _devBaseUrl = kIsWeb 
  //     ? "http://localhost:8000" 
  //     : (Platform.isAndroid 
  //         ? "http://10.0.2.2:8000" 
  //         : "http://localhost:8000");

  // Alterne entre produção e desenvolvimento aqui
  // Para testar localmente com o emulador, use _devBaseUrl.
  // Para fazer o deploy do app, mude para _prodBaseUrl.
  // static final String baseUrl = _devBaseUrl; 
  static const String baseUrl = _prodBaseUrl; 

  // O endpoint do proxy de imagem continua o mesmo
  static final String imageProxyUrlPrefix = "$baseUrl/proxy/image?url=";
}
