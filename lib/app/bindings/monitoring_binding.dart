import 'package:get/get.dart';
// import 'package:loot_app/app/controllers/monitoring_controller.dart';
// Se o MonitoringController precisar de um provider específico, importe e registre aqui.

class MonitoringBinding extends Bindings {
  @override
  void dependencies() {
    // O MonitoringController já é registrado pelo MainNavigationBinding com fenix:true.
    // Este binding individual pode não ser estritamente necessário se MonitoringScreenContent
    // for sempre acessada como uma aba da MainNavigationScreen.
    // No entanto, se você planeja ter uma rota direta para MonitoringScreen no futuro,
    // ou se quiser uma organização mais granular, pode mantê-lo.
    // Se MainNavigationBinding já faz Get.lazyPut<MonitoringController>(..., fenix: true),
    // esta linha abaixo pode ser redundante ou até causar um aviso se não usar um tag diferente.
    // Por ora, vamos assumir que MainNavigationBinding cuida da instância principal.
    // Get.lazyPut<MonitoringController>(() => MonitoringController());
    print("[MonitoringBinding] Chamado (geralmente não precisa registrar controller aqui se MainNavBinding já o faz com fenix:true)");
  }
}