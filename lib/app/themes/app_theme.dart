// lib/app/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.deepPurple, // Escolha sua cor primária
    // Exemplo de cor de botão para combinar com o tom "Loot" (caça ao tesouro, etc.)
    // Pode ser um tom de laranja, amarelo escuro, ou marrom.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent, // Exemplo
        foregroundColor: Colors.white,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple, // Exemplo
      foregroundColor: Colors.white, // Cor do texto e ícones da AppBar
    ),
    // Você pode definir mais aspectos do tema aqui
    // fontFamily: 'SuaFonteCustomizada', // Se tiver uma
  );

  // static final ThemeData darkTheme = ThemeData.dark().copyWith(...); // Para tema escuro
}