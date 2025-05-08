// File: /lib/pages/register_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/my_button.dart';
import 'package:marketplaceappv4/components/my_textfield.dart';
import 'package:marketplaceappv4/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordStrong(String password) {
    //  one uppercase, one lowercase, one digit, one special character , minimum 8 characters.
    final passwordRegEx = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegEx.hasMatch(password);
  }

  // Register method
  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);

      displayMessageToUser("Passwords do not match", context);
      return;
    }

    // Check strong password criteria
    if (!isPasswordStrong(passwordController.text)) {
      Navigator.pop(context);

      displayMessageToUser("Password must be at least 8 characters and include uppercase, lowercase, digit and symbol", context);
      return;
    }

    try {
      // Create the user with email and password
      UserCredential? userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Send verification email
      await userCredential.user!.sendEmailVerification();

      // Create user profile in Firestore
      await createUserDocument(userCredential);

      Navigator.pop(context);

      // Inform the user to verify their email
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Verify your email"),
          content: const Text("A verification email has been sent to your email address. Please verify your email before logging in."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Optionally sign out the user so they must log in after verification
                FirebaseAuth.instance.signOut();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessageToUser(e.code, context);
    }
  }


  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
        "username": usernameController.text,
        "email": userCredential.user!.email,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.add_business_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              const SizedBox(height: 50),
              // App name
              const Text(
                "marketplace ",
                style: TextStyle(fontSize: 20, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              // Username Field
              MyTextField(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
              ),
              const SizedBox(height: 25),
              // Email Field
              MyTextField(
                hintText: "Email",
                obscureText: false,
                controller: emailController,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter a password";
                  }
                  if (!isPasswordStrong(value)) {
                    return "Password must be 8+ chars, include uppercase, lowercase, number and symbol";

                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Confirm Password Field
              MyTextField(
                hintText: "Confirm Password",
                obscureText: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 10),
              // Forgot Password (for UI consistency)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              // Register Button
              MyButton(
                text: "Register",
                onTap: registerUser,
              ),
              const SizedBox(height: 20),
              // Toggle to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Login Here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
