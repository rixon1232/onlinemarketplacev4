import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    background: Colors.black,
    primary: Colors.deepPurple.shade700,
    secondary: Colors.tealAccent.shade200,
    inversePrimary: Colors.white,
    surface: Colors.grey.shade900,
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.black,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white,                     // Overall body text color
    displayColor: Colors.white70,                // Display text color
  ),
);
