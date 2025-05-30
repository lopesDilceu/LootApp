import 'package:get/get.dart';
import 'package:loot_app/app/services/auth/auth_service.dart';
import 'package:loot_app/app/data/models/user_model.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService.to;

  // User pode ser nulo se, por algum motivo, esta tela for acessada sem login
  // mas o AuthService deve ter o usuário se isLoggedIn for true.
  User? get user => _authService.currentUser.value;

  // Adicione aqui lógica para editar perfil, etc.
  // Por exemplo:
  // final RxBool isLoading = false.obs;
  // final TextEditingController nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      print("[ProfileController] Usuário no perfil: ${user!.email}");
      // nameController.text = user!.firstName; // Exemplo se for editar
    } else {
      print("[ProfileController] ATENÇÃO: Usuário nulo na tela de perfil.");
      // Idealmente, um middleware de rota impediria acesso a esta tela sem login.
    }
  }

  // @override
  // void onClose() {
  //   nameController.dispose();
  //   super.onClose();
  // }
}