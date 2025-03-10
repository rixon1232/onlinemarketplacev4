import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/my_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  //logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const  Text('Home'),
        backgroundColor:Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,


      ),
      drawer: MyDrawer(),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
