import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/my_button.dart';
import 'package:marketplaceappv4/components/my_textfield.dart';
import 'package:marketplaceappv4/components/my_textfield.dart';
import 'package:marketplaceappv4/components/my_button.dart';
import 'package:marketplaceappv4/helper/helper_functions.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;


  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  //login method
  void login() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
         child: CircularProgressIndicator(),
        ),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );

      if (context.mounted) Navigator.pop(context);
    }
      on FirebaseAuthException catch (e){
        Navigator.pop(context);
        displayMessageToUser(e.code,context);
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

                MyButton(text:"login",
                  onTap: login,
                ),
                const SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Don't have an account? " ,style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)
                    ),

                    GestureDetector(
                        onTap: widget.onTap,
                        child: const Text (
                       " Register Here",
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