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

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark, // Define o brilho como escuro
    primarySwatch: Colors.deepPurple, // Mantenha sua cor primária ou escolha uma nova para o tema escuro
    // Exemplo: primaryColor: Colors.deepPurple[700],
    // accentColor: Colors.amber,
     colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple,
      accentColor: Colors.amberAccent, // Cor de destaque
      brightness: Brightness.dark, // Importante para cores de componentes padrão
    ),
    fontFamily: 'Nunito', // Sua fonte padrão
    scaffoldBackgroundColor: Colors.grey[900], // Fundo escuro
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850], // Cor da AppBar no tema escuro
      foregroundColor: Colors.white,     // Cor do texto e ícones na AppBar
      titleTextStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey[850],
      selectedItemColor: Colors.amberAccent, // Cor de destaque para itens selecionados
      unselectedItemColor: Colors.grey[400],
    ),
    // ... outras personalizações do tema escuro (cores de card, botões, texto, etc.)
    // Exemplo para Cards:
    // cardTheme: CardTheme(
    //   color: Colors.grey[800],
    //   elevation: 2,
    // ),
    // Exemplo para TextFields:
    // inputDecorationTheme: InputDecorationTheme(
    //   focusedBorder: OutlineInputBorder(
    //     borderSide: BorderSide(color: Colors.amberAccent),
    //   ),
    //   labelStyle: TextStyle(color: Colors.grey[400]),
    // ),
  );

  // static final ThemeData darkTheme = ThemeData.dark().copyWith(...); // Para tema escuro
}