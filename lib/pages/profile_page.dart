// File: /lib/pages/profile_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';

class ProfilePage extends StatefulWidget {

  final String? userEmail;

  const ProfilePage({super.key, this.userEmail});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bioController = TextEditingController();

  // Use the passed userEmail or default to the current user's email.
  String get displayEmail {
    return widget.userEmail ?? FirebaseAuth.instance.currentUser!.email!;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(displayEmail)
        .get();
  }

  void editBio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bio"),
        content: TextField(
          controller: bioController,
          decoration: const InputDecoration(hintText: "Enter your bio"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(displayEmail)
                    .update({'bio': bioController.text});
                bioController.clear();
                if (context.mounted) {
                  Navigator.pop(context);
                }
                setState(() {});
              } catch (e) {
                print("Error updating bio: $e");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void signOut() async {
    // Only allow sign out if we're viewing the current user's profile.
    if (widget.userEmail == null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is the current user's profile.
    bool isCurrentUser = widget.userEmail == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          if (isCurrentUser)
            IconButton(
              onPressed: signOut,
              icon: const Icon(Icons.logout),
            )
        ],
      ),
      drawer: isCurrentUser ? const MyDrawer() : null,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              Map<String, dynamic>? user = snapshot.data!.data();
              if (user == null) {
                return const Center(child: Text("User data not found"));
              }
              return ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['username'] ?? "No Username",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  user['email'] ?? "No Email",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          user['bio'] ?? "Add Bio",
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .inversePrimary),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: GestureDetector(
                            onTap: editBio,
                            child: Text(
                              "Edit Bio",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              );
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
      ),
    );
  }
}

