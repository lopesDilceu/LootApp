import 'package:loot_app/app/data/models/user_model.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  String get firstName => user.firstName;
}