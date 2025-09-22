import 'package:flutter/material.dart';

class AppTheme {
  final String primary;
  final String secondary;
  final bool isDarkMode;
  AppTheme({this.primary = '', this.secondary = '', this.isDarkMode = false});

  ThemeData getTheme() {
    Color primaryColor =
        Color(int.parse(primary.substring(1, 7), radix: 16) + 0xFF000000);
    Color secondaryColor =
        Color(int.parse(secondary.substring(1, 7), radix: 16) + 0xFF000000);

    Color defaultTextColor = isDarkMode ? Colors.white : Colors.black;
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      brightness: brightness,
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
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),

      ///* FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4, // Elevación del FAB
        backgroundColor: colorScheme.secondary,
        // foregroundColor: colorScheme.onSecondary,
      ),
    );
  }

  AppTheme copyWith({String? primary, String? secondary, bool? isDarkMode}) =>
      AppTheme(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );
}
