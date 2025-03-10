import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
//logout user
  void logout() {
    FirebaseAuth.instance.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
          DrawerHeader(
            child: Icon(Icons.favorite,),
          ),
          const SizedBox(height: 25,),



          //home tile

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              leading: Icon(Icons.home,
              color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                //hides pop up draw
                Navigator.pushNamed(context, '/home_page');
              }
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
                leading: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: const Text('Profile'),
                onTap: () {
                  //hides pop up draw
                  Navigator.pop(context);
                  //navigates to profile page
                  Navigator.pushNamed(context, '/profile_page');
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
                leading: Icon(Icons.group,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: Text('messages'),
                onTap: () {
                  Navigator.pop(context);
                  //hides pop up draw
                  Navigator.pop(context);
                  //navigates to users page
                  Navigator.pushNamed(context, '/user_page');
                }
            ),
          ),
       ],
     ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
                leading: Icon(Icons.logout,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  //logout user
                  logout();

                }
            ),
          ),
      ],//profile tile

     ),
    );
  }
}

    