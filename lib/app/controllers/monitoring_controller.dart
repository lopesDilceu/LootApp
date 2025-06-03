import 'package:get/get.dart';

class MonitoringController extends GetxController {
  // Adicione aqui a lógica para buscar e gerenciar jogos monitorados
  // Exemplo:
  // var monitoredGames = <MonitoredGameModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("[MonitoringController] onInit chamado.");
    // fetchMonitoredGames(); // Exemplo de chamada inicial
  }

  // void fetchMonitoredGames() async {
  //   isLoading.value = true;
  //   // Lógica para buscar do backend ou storage local
  //   await Future.delayed(Duration(seconds: 1)); // Simula busca
  //   // monitoredGames.assignAll(...);
  //   isLoading.value = false;
  // }

  // void addGameToMonitor(String gameId, String title, double targetPrice) {
  //   // Lógica para adicionar ao backend/storage e à lista local
  // }

  // void removeGameFromMonitor(String monitoringId) {
  //   // Lógica para remover
  // }
}