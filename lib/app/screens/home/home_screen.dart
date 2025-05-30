// lib/app/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:loot_app/app/controllers/home_controller.dart';
import 'package:loot_app/app/widgets/common/app_bar.dart'; // Verifique o caminho

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Bem-vindo ao Loot!',
        showBackButton: false, // Geralmente a home não tem botão de voltar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // TODO: Adicionar seu logo aqui!
              // Exemplo:
              // Image.asset(
              //  'assets/images/loot_logo.png', // Crie esta pasta e adicione seu logo
              //  height: 150,
              //  errorBuilder: (context, error, stackTrace) { // Fallback se a imagem não carregar
              //    return const Icon(Icons.shopping_bag_outlined, size: 120, color: Colors.grey);
              //  },
              // ),
              const Icon(Icons.shopping_bag_outlined, size: 120, color: Colors.grey), // Placeholder
              const SizedBox(height: 40),
              Text(
                'Sua Caçada por Promoções Começa Aqui!',
                textAlign: TextAlign.center,
                style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Descubra as melhores ofertas de jogos e economize na sua próxima aventura gamer.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // backgroundColor: Colors.amber, // Exemplo de cor
                  // foregroundColor: Colors.black, // Exemplo de cor
                ),
                onPressed: controller.navigateToLogin, // Chama o método do controller
                child: const Text('Acessar / Cadastrar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final storage = const FlutterSecureStorage();
                  const testKey = 'myWebTestKey';
                  const testValue = 'HelloWebStorage123';
                  try {
                    print("WEB_STORAGE_TEST: Tentando escrever...");
                    await storage.write(key: testKey, value: testValue);
                    print("WEB_STORAGE_TEST: Escrita (tentativa) concluída.");

                    // Verifique o localStorage no DevTools do navegador aqui!
                    // Deve haver uma chave como flutter_secure_storage.myWebTestKey (o prefixo pode variar)

                    final readValue = await storage.read(key: testKey);
                    print("WEB_STORAGE_TEST: Valor lido: $readValue");

                    if (readValue == testValue) {
                      Get.snackbar("Teste Storage Web", "Sucesso: Escreveu e Leu!", backgroundColor: Colors.green);
                    } else {
                      Get.snackbar("Teste Storage Web", "Falha: Valor lido ($readValue) diferente do escrito ($testValue)", backgroundColor: Colors.red);
                    }
                  } catch (e) {
                    print("WEB_STORAGE_TEST: EXCEÇÃO: $e");
                    Get.snackbar("Teste Storage Web", "EXCEÇÃO: $e", backgroundColor: Colors.orange);
                  }
                },
                child: Text("Testar Secure Storage Web"),
              )
            ],
          ),
        ),
      ),
    );
  }
}