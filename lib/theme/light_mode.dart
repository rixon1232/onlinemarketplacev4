import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    background: Colors.amber.shade50,
    primary: Colors.amber.shade100,
    secondary: Colors.lightGreen.shade500,
    inversePrimary: Colors.green.shade900,
    surface: Colors.white,
    onPrimary: Colors.black,
    onBackground: Colors.black87,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    onSurface: Colors.black,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black87,
    displayColor: Colors.black87,
  ),
);
