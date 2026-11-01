import 'package:flutter/material.dart';
import 'package:ultrared/main.dart';

class AppTheme {
  /// Colores base de la empresa cuando el login no devuelve colores.
  static const String baseColorPrimario = '#5A0A1C';
  static const String baseColorSecundario = '#60605E';

  /// Colores base puros (sin tonalización de Material) para usarlos tal cual.
  static const Color basePrimaryColor = Color(0xFF5A0A1C);
  static const Color baseSecondaryColor = Color(0xFF60605E);

  final String primary;
  final String secondary;
  final bool isDarkMode;
  AppTheme({this.primary = '', this.secondary = '', this.isDarkMode = false});

  ThemeData getTheme() {
    Color primaryColor = _hexToColor(primary, basePrimaryColor);
    Color secondaryColor = _hexToColor(secondary, baseSecondaryColor);

    Color defaultTextColor = isDarkMode ? Colors.white : Colors.black;
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final Color onPrimary = primaryColor.contrastText;
    final Color onSecondary = secondaryColor.contrastText;
    // El resto de la paleta se genera con Material 3, pero primario y
    // secundario quedan en el hex exacto que envió el servidor.
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
      primary: primaryColor,
      onPrimary: onPrimary,
      secondary: secondaryColor,
      onSecondary: onSecondary,
      surfaceTint: primaryColor,
    );
    return ThemeData(
      brightness: brightness,
      fontFamily: 'Roboto',

      colorScheme: colorScheme,

      ///* General
      useMaterial3: true,

      ///* Texts
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: defaultTextColor,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: defaultTextColor,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          color: defaultTextColor,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          color: defaultTextColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: defaultTextColor,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          color: defaultTextColor,
        ),
      ),

      ///* Buttons
      // filledButtonTheme: FilledButtonThemeData(
      //   style: ButtonStyle(
      //     backgroundColor: WidgetStateProperty.all(primaryColor),
      //     textStyle: WidgetStateProperty.all(
      //       const TextStyle(
      //         fontFamily: 'Roboto',
      //         fontWeight: FontWeight.w700,
      //       ),
      //     ),
      //   ),
      // ),

      ///* AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onPrimary,
        iconTheme: IconThemeData(color: onPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: onPrimary,
        ),
      ),

      ///* FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4, // Elevación del FAB
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.primary.contrastText,
      ),
    );
  }

  /// Convierte un color hex (#RRGGBB) a [Color]. Si el valor es vacío,
  /// nulo o inválido, devuelve el [fallback] (color base de la empresa).
  static Color _hexToColor(String hex, Color fallback) {
    try {
      final cleaned = hex.replaceAll('#', '').trim();
      if (cleaned.length != 6) return fallback;
      return Color(int.parse(cleaned, radix: 16) + 0xFF000000);
    } catch (_) {
      return fallback;
    }
  }

  AppTheme copyWith({String? primary, String? secondary, bool? isDarkMode}) =>
      AppTheme(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );
}
