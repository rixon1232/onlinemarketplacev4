// File: /lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/auth/login_or_register.dart';
import 'package:marketplaceappv4/pages/add_listing.dart';
import 'package:marketplaceappv4/pages/home_page.dart';
import 'package:marketplaceappv4/pages/my_profile_page.dart';
import 'package:marketplaceappv4/pages/seller_profile_page.dart';
import 'package:marketplaceappv4/pages/user_page.dart';
import 'package:marketplaceappv4/theme/dark_mode.dart';
import 'package:marketplaceappv4/theme/light_mode.dart';
import 'firebase_options.dart';
import 'package:marketplaceappv4/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/LoginOrRegister': (context) => const LoginOrRegister(),
        '/home_page': (context) => const HomePage(),
        '/my_profile': (context) => const MyProfilePage(),
        '/user_page': (context) => const UserPage(),
        '/add_listing': (context) => const AddListingPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/seller_profile') {
          final sellerEmail = settings.arguments;
          if (sellerEmail == null || sellerEmail is! String) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text("Seller data not provided.")),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => SellerProfilePage(sellerEmail: sellerEmail),
          );
        }
        return null;
      },
    );
  }
}


