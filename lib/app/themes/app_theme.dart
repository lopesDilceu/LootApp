// lib/app/themes/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // --- PASSO 3: ATUALIZE A CONSTANTE DA FAMÍLIA DA FONTE ---
  static const String _fontFamily =
      'Roboto'; // Alterado de 'Nunito' para 'Roboto' (ou sua fonte escolhida)

  // --- TEMA CLARO ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: _fontFamily, // Aplica a nova fonte globalmente
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: Colors.grey[100],

    colorScheme: ColorScheme.light(
      primary: Colors.blueGrey[700]!,
      onPrimary: Colors.white,
      secondary: Colors.teal[600]!,
      onSecondary: Colors.white,
      background: Colors.grey[100]!,
      onBackground: Colors.black87,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: Colors.red[700]!,
      onError: Colors.white,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[800],
      foregroundColor: Colors.white,
      elevation: 1.0,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily, // Garante que a AppBar use a nova fonte
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[700],
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte para botões
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueGrey[700],
        side: BorderSide(color: Colors.blueGrey[300]!),
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueGrey[700],
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blueGrey[700]!, width: 2.0),
      ),
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[700],
      ), // Nova fonte
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[500],
      ), // Nova fonte
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueGrey[700],
      unselectedItemColor: Colors.grey[500],
      elevation: 4.0,
      // Os labels da BottomNavigationBar usarão a fontFamily global se não especificado aqui
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[800],
      ), // Nova fonte
    ),

    textTheme: TextTheme(
      // Exemplo de como customizar estilos específicos com a nova fonte
      displayLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displayMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displaySmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      headlineMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      headlineSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ), // Ajustado para melhor contraste
      titleLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      titleMedium: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.black54,
      ),
      titleSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        color: Colors.black54,
      ),
      bodyLarge: TextStyle(fontFamily: _fontFamily, color: Colors.grey[800]),
      bodyMedium: TextStyle(fontFamily: _fontFamily, color: Colors.grey[800]),
      bodySmall: TextStyle(fontFamily: _fontFamily, color: Colors.grey[700]),
      labelLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ), // Para botões com fundo colorido
      labelMedium: TextStyle(fontFamily: _fontFamily, color: Colors.grey[700]),
      labelSmall: TextStyle(fontFamily: _fontFamily, color: Colors.grey[700]),
    ),

    iconTheme: IconThemeData(color: Colors.blueGrey[700]),
    listTileTheme: ListTileThemeData(
      // Os Text dentro de ListTile herdarão do textTheme, mas você pode especificar aqui se necessário
      // titleTextStyle: TextStyle(fontFamily: _fontFamily, color: Colors.black87),
      // subtitleTextStyle: TextStyle(fontFamily: _fontFamily, color: Colors.grey[700]),
    ),
  );

  // --- TEMA ESCURO ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: _fontFamily, // Aplica a nova fonte globalmente
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: const Color(0xFF121212),

    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey[300]!,
      onPrimary: Colors.black,
      secondary: Colors.teal[300]!,
      onSecondary: Colors.black,
      background: const Color(0xFF121212),
      onBackground: Colors.white70,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      error: Colors.redAccent[200]!,
      onError: Colors.black,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 1.0,
      titleTextStyle: const TextStyle(
        fontFamily: _fontFamily, // Nova fonte
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey[600],
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blueGrey[200],
        side: BorderSide(color: Colors.blueGrey[700]!),
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueGrey[200],
        textStyle: const TextStyle(
          fontFamily: _fontFamily, // Nova fonte
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFF2A2A2A),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blueGrey[300]!, width: 2.0),
      ),
      labelStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[400],
      ), // Nova fonte
      hintStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[600],
      ), // Nova fonte
      prefixIconColor: Colors.grey[400],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: Colors.blueGrey[200],
      unselectedItemColor: Colors.grey[500],
      elevation: 4.0,
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      textStyle: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ), // Nova fonte
    ),

    textTheme: TextTheme(
      // Exemplo de como customizar estilos específicos com a nova fonte
      displayLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineMedium: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      headlineSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
      titleLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ),
      titleSmall: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      bodyLarge: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ),
      bodyMedium: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontFamily,
        color: Colors.grey[400],
      ), // Ajustado para texto menor
      labelLarge: const TextStyle(
        fontFamily: _fontFamily,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ), // Para botões com fundo claro no tema escuro
      labelMedium: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ),
      labelSmall: const TextStyle(
        fontFamily: _fontFamily,
        color: Colors.white70,
      ),
    ),
    iconTheme: IconThemeData(color: Colors.blueGrey[200]),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.blueGrey[200],
      // titleTextStyle: TextStyle(fontFamily: _fontFamily, color: Colors.white),
      // subtitleTextStyle: TextStyle(fontFamily: _fontFamily, color: Colors.white70),
    ),
  );
}
