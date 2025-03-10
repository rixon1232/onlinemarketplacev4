import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/my_button.dart';
import 'package:marketplaceappv4/components/my_textfield.dart';
import 'package:marketplaceappv4/helper/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterPage extends StatefulWidget {
  final void Function()? onTap;


  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController = TextEditingController();

  // Register method
  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) =>
      const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      displayMessageToUser("Passwords do not match", context);
    }
    else {
      try {
        UserCredential? userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        //create user profile using firestore
        createUserDocument(userCredential);

        if(context.mounted)Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);

        displayMessageToUser(e.code, context);
      }
    }
  }
     //user document
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance.
      collection("Users")
          .doc(userCredential.user!.email)
          .set({
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
                //logo
                Icon(
                  Icons.add_business_rounded,
                  size:80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),

                const SizedBox(height: 50,),
                //app name
                const Text(
                  "marketplace ",
                  style: TextStyle(fontSize: 20,fontFamily: 'Roboto', fontWeight: FontWeight.bold,),
                ),

                const SizedBox(height: 25,),

                //username
                MyTextField(
                  hintText: "Username",
                  obscureText: false,
                  controller: usernameController,
                ),
                const SizedBox(height: 25,),

                //email
                MyTextField(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController,
                ),

                const SizedBox(height: 10,),
                //password
                MyTextField(
                  hintText: "password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 10,),
                // confirm password
                MyTextField(
                  hintText: "Confirm password",
                  obscureText: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 10,),
                //forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                    )
                  ],
                ),
                const SizedBox(height: 50,),

                MyButton(text:"Register",
                  onTap: registerUser,
                ),
                const SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "already have an account? " ,style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)
                    ),

                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text (
                        " login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ) ,
                      ),
                    ),
                  ],
                )



              ],
            ),
          ),
        )

    );
  }
}