import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marketplaceappv4/helper/helper_functions.dart';

void main() {
  testWidgets('displayMessageToUser shows AlertDialog with the message', (WidgetTester tester) async {
    // Build a minimal app to host the dialog
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () {
            displayMessageToUser('Hello Test', context);
          },
          child: Text('Show'),
        );
      }),
    ));

    // Tap the button to trigger the dialog
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    // Expect an AlertDialog with our message
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Hello Test'), findsOneWidget);
  });
}
