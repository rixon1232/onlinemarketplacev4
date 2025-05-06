import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void displayMessageToUser(String message,BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
  );

}