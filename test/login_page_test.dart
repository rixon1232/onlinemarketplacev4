// File: test/widget_and_theme_tests.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplaceappv4/components/my_button.dart';
import 'package:marketplaceappv4/components/my_textfield.dart';
import 'package:marketplaceappv4/helper/helper_functions.dart';
import 'package:marketplaceappv4/theme/light_mode.dart';
import 'package:marketplaceappv4/theme/dark_mode.dart';

void main() {
  group('displayMessageToUser', () {
    testWidgets('shows an AlertDialog with the provided message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => displayMessageToUser('Test Message', context),
            child: Text('Show'),
          );
        }),
      ));

      // Tap the button to open the dialog
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
    });
  });

  group('MyButton widget', () {
    testWidgets('renders its text and responds to taps', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: 'Click Me',
            onTap: () => tapped = true,
          ),
        ),
      ));

      // Verify the button text
      expect(find.text('Click Me'), findsOneWidget);

      // Tap and verify callback
      await tester.tap(find.text('Click Me'));
      expect(tapped, isTrue);
    });
  });

  group('MyTextField widget', () {
    testWidgets('shows hintText and default obscureText=false', (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            hintText: 'Enter text',
            obscureText: false,
            controller: controller,
          ),
        ),
      ));

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration!.hintText, 'Enter text');
      expect(tf.obscureText, isFalse);
    });

    testWidgets('obscureText=true hides input but retains controller value', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'secret');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            hintText: 'Password',
            obscureText: true,
            controller: controller,
          ),
        ),
      ));

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.decoration!.hintText, 'Password');
      expect(tf.obscureText, isTrue);
      expect(controller.text, 'secret');
    });
  });

  group('ThemeData objects', () {
    test('lightMode has brightness light and non-null colorScheme', () {
      expect(lightMode.brightness, Brightness.light);
      expect(lightMode.colorScheme.brightness, Brightness.light);
      expect(lightMode.colorScheme.primary, isNotNull);
    });

    test('darkMode has brightness dark and non-null colorScheme', () {
      expect(darkMode.brightness, Brightness.dark);
      expect(darkMode.colorScheme.brightness, Brightness.dark);
      expect(darkMode.colorScheme.primary, isNotNull);
    });
  });
}
