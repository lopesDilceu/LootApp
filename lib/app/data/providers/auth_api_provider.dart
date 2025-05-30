// lib/app/data/providers/auth_api_provider.dart
// ignore_for_file: avoid_print, unused_local_variable

import 'package:flutter/material.dart'; // Para Cores no Get.snackbar
import 'package:get/get.dart';
import 'package:loot_app/app/data/models/auth/auth_response_model.dart';
import 'package:loot_app/app/data/models/user_model.dart';
import 'package:loot_app/app/constants/api/api_constants.dart'; // **IMPORTANTE: Crie este arquivo!**

// **OPCIONAL: Importe seu serviço de armazenamento para gerenciar o token**
// import 'package:loot_app/app/services/storage_service.dart';

class AuthApiProvider extends GetConnect {
  // **OPCIONAL: Instância do seu serviço de armazenamento**
  // final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    // **MUITO IMPORTANTE:** Defina a URL base da sua API no arquivo!
    // Ex: `lib/app/shared/constants/api_constants.dart`
    // Conteúdo de api_constants.dart:
    // class ApiConstants {
    //   static const String baseUrl = "https://sua-api.com/api"; // SUBSTITUA PELA SUA URL
    // }
    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(
      seconds: 30,
    ); // Define um timeout para as requisições

    // **OPCIONAL: Interceptor para adicionar o token de autenticação automaticamente**
    // Este trecho adicionaria o token salvo a todas as requisições futuras.
    // httpClient.addRequestModifier<void>((request) async {
    //   final token = await _storageService.getToken(); // Método para buscar o token salvo
    //   if (token != null && token.isNotEmpty) {
    //     request.headers['Authorization'] = 'Bearer $token';
    //   }
    //   return request;
    // });

    // **OPCIONAL: Interceptor para tratar respostas globais (ex: 401 - Não Autorizado)**
    // httpClient.addResponseModifier((request, response) {
    //   if (response.statusCode == 401) {
    //     // Exemplo: Limpar dados do usuário e redirecionar para a tela de login
    //     // _storageService.clearUserData(); // Método para limpar dados salvos
    //     // Get.offAllNamed(AppRoutes.LOGIN); // Redireciona para o login
    //     Get.snackbar('Sessão Expirada', 'Por favor, faça login novamente.',
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
    //   }
    //   return response;
    // });
  }

  // Método para Login
  Future<AuthResponse?> login({required String email, required String password}) async {
    const String loginEndpoint = "login/"; // Confirme seu endpoint
    print("[AuthApiProvider] Iniciando login para: $email");
    print("[AuthApiProvider] URL: ${httpClient.baseUrl}$loginEndpoint");

    try {
      final response = await post(loginEndpoint, {
        'email': email,
        'password': password,
      });

      // Log crucial: Veja o que o Flutter recebeu
      print("[AuthApiProvider] Status da Resposta: ${response.statusCode}");
      print(
        "[AuthApiProvider] Corpo da Resposta (Raw): ${response.bodyString}",
      ); // Imprime o JSON cru como string

      if (response.isOk) {
        // Verifica se o status code é 2xx (sucesso)
        if (response.body != null &&
            response.body
                is Map && // Garante que o corpo é um mapa antes de acessar chaves
            response.body['token'] != null &&
            response.body['user'] != null) {
          print(
            "[AuthApiProvider] Token e User encontrados no corpo da resposta.",
          );
          try {
            final user = User.fromJson(response.body['user']);
            final String token = response.body['token'];

            print(
              "[AuthApiProvider] Usuário parseado: ${user.firstName}, Email: ${user.email}",
            );
            print(
              "[AuthApiProvider] Token recebido (início): ${token.substring(0, token.length > 10 ? 10 : token.length)}...",
            );

            // TODO: SALVAR O TOKEN DE FORMA SEGURA AQUI!
            // Ex: await _storageService.saveToken(token);

            return AuthResponse(user: user, token: token);
          } catch (e) {
            print(
              "[AuthApiProvider] ERRO ao parsear User.fromJson ou token: $e",
            );
            Get.snackbar(
              "Erro de Login",
              "Erro ao processar dados do usuário.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return null;
          }
        } else {
          print(
            "[AuthApiProvider] ERRO: Corpo da resposta OK, mas 'user' ou 'token' estão faltando ou não são um mapa.",
          );
          print("[AuthApiProvider] Detalhes do corpo: ${response.body}");
          Get.snackbar(
            "Erro de Login",
            "Resposta inesperada do servidor (campos faltando).",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
      } else {
        // A API retornou um erro (status code não é 2xx)
        print(
          "[AuthApiProvider] Falha no login com status ${response.statusCode}.",
        );
        String errorMessage = "Não foi possível fazer login.";
        if (response.body != null &&
            response.body is Map &&
            response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else if (response.statusText != null &&
            response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }
        Get.snackbar(
          "Erro de Login (${response.statusCode})",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      // Este é o catch que você mencionou anteriormente.
      // A mensagem de "unsafe header" NÃO é esta exceção.
      // Esta exceção 'e' seria um erro de conexão, timeout, etc.
      print("[AuthApiProvider] EXCEÇÃO na chamada HTTP: $e");
      Get.snackbar(
        "Erro de Login",
        "Ocorreu um erro de conexão. Verifique sua internet.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // Método para Cadastro
  Future<AuthResponse?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    Role role =
        Role.user, // Confirme se o 'role' é enviado ou definido no backend
  }) async {
    // **IMPORTANTE: Ajuste o endpoint se necessário**
    const String registerEndpoint =
        "users/create/"; // Ou o endpoint de cadastro da sua API

    try {
      final response = await post(registerEndpoint, {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role.name, // Envia 'user' ou 'admin' como string
      });

      if (response.isOk) {
        if (response.body != null &&
            response.body['user'] != null &&
            response.body['token'] != null) {
          final user = User.fromJson(response.body['user']);
          final String token = response.body['token'];

          // TODO: Salve o 'token' de forma segura aqui (similar ao login)!
          // Ex: await _storageService.saveToken(token);
          // Ex: await _storageService.saveUser(user);

          return AuthResponse(user: user, token: token);
        } else {
          Get.snackbar(
            "Erro de Cadastro",
            "Resposta inesperada do servidor após cadastro.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          print(
            "Register Error: Invalid response body. Body: ${response.bodyString}",
          );
          return null;
        }
      } else {
        String errorMessage = "Não foi possível realizar o cadastro.";
        if (response.body != null && response.body['message'] != null) {
          errorMessage = response.body['message'];
        } else if (response.statusText != null &&
            response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }
        Get.snackbar(
          "Erro de Cadastro (${response.statusCode})",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(
          "Register Error (${response.statusCode}): ${response.bodyString}",
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        "Erro de Cadastro",
        "Ocorreu um erro de conexão. Verifique sua internet ou tente mais tarde.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Register Exception: $e");
      return null;
    }
  }
}
