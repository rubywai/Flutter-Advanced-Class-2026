import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.indigoAccent,
        titleTextStyle: TextStyle(
          color: Colors.indigo,
          inherit: false,
          fontSize: 16,
        ),
        subtitleTextStyle: TextStyle(
          color: Colors.indigoAccent,
          inherit: false,
          fontSize: 13,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.indigo),
        contentTextStyle: TextStyle(color: Colors.indigoAccent),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigoAccent),
        ),
        labelStyle: TextStyle(color: Colors.indigoAccent),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.indigo),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.indigo,
          side: BorderSide(color: Colors.indigo),
        ),
      ),
    );
  }

  static ThemeData dartTheme() {
    return ThemeData.dark().copyWith();
  }
}
