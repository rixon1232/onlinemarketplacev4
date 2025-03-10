import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light, // Set ThemeData.brightness to light
  colorScheme: ColorScheme.light(
    brightness: Brightness.light, // Set ColorScheme.brightness to light
    background: Colors.blueGrey,
    primary: Colors.grey.shade50,
    secondary: Colors.grey.shade500,
    inversePrimary: Colors.grey.shade800,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey.shade800,
    displayColor: Colors.black38,
  ),
);