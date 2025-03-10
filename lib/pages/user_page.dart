import 'package:flutter/material.dart';

import '../components/my_drawer.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
           title: Text("messages"),
           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
         elevation: 0,
       ),
        drawer: MyDrawer()
    );
  }
}
