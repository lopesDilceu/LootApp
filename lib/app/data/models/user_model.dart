// lib/app/data/models/user_model.dart

// Enum para o papel do usuário
enum Role {
  user,
  admin,
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final Role role;
  final String email;
  // O 'rememberToken' aqui representa o token (ex: JWT) que sua API retorna após o login/cadastro.
  // O nome do campo pode variar na sua API (ex: 'token', 'accessToken').
  final String? rememberToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.email,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  // Factory constructor para criar uma instância de User a partir de um JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: (json['role'] as String).toRole(), // Usa a extensão para converter String para Enum
      email: json['email'] as String,
      // Ajuste 'rememberToken' se o nome do campo do token na sua API for diferente (ex: json['token'])
      rememberToken: json['rememberToken'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
    );
  }

  // Método para converter uma instância de User para JSON (útil se você precisar enviar o objeto User para a API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.name, // Converte o Enum para String (ex: 'user', 'admin')
      'email': email,
      'rememberToken': rememberToken,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}

// Extensão para converter a string do 'role' (vindo do JSON) para o enum Role
extension RoleExtension on String {
  Role toRole() {
    switch (toLowerCase()) {
      case 'admin':
        return Role.admin;
      case 'user':
      default: // Garante um valor padrão se a string não corresponder
        return Role.user;
    }
  }
}