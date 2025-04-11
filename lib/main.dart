import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/auth/auth.dart';
import 'package:marketplaceappv4/auth/login_or_register.dart';
import 'package:marketplaceappv4/pages/add_listing.dart';
import 'package:marketplaceappv4/pages/home_page.dart';
import 'package:marketplaceappv4/pages/my_profile_page.dart';
import 'package:marketplaceappv4/pages/seller_profile_page.dart';
import 'package:marketplaceappv4/pages/conversations_page.dart'; // if you have it
import 'package:marketplaceappv4/theme/dark_mode.dart';
import 'package:marketplaceappv4/theme/light_mode.dart';
import 'firebase_options.dart';
import 'package:marketplaceappv4/pages/chat_detail_page.dart';
import 'package:marketplaceappv4/pages/listing_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Marketplace App',
      theme: lightMode,
      darkTheme: darkMode,
      home: const AuthPage(),
      routes: {
        '/login_or_register': (context) => const LoginOrRegister(),
        '/home_page': (context) => const ToggleHomePage(),
        '/my_profile': (context) => const MyProfilePage(),
        '/add_listing': (context) => const AddListingPage(),
        '/seller_profile': (context) => SellerProfilePage(
          sellerEmail:
          ModalRoute.of(context)?.settings.arguments as String? ??
              "unknown",
        ),
        // Optionally, route for a Conversations page if you have one.
        '/conversations': (context) => const ConversationsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat_detail') {
          final conversationId = settings.arguments as String?;
          if (conversationId == null || conversationId.trim().isEmpty) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text("Chat")),
                body: Center(
                  child: Text(
                    "Invalid conversation ID",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => ChatDetailPage(conversationId: conversationId),
          );
        }
        return null;
      },
    );
  }
}
