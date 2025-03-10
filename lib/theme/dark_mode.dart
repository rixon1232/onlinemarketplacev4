import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark, // Set ThemeData.brightness to dark
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark, // Set ColorScheme.brightness to dark
    background: Colors.grey.shade900,
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade50,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade50,
    displayColor: Colors.white70,
  ),
);