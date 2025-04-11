// File: /lib/pages/my_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../helper/helper_functions.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final bioController = TextEditingController();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    return FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
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
                    .doc(currentUser!.email)
                    .update({'bio': bioController.text});
                bioController.clear();
                if (context.mounted) Navigator.pop(context);
                setState(() {});
              } catch (e) {
                displayMessageToUser("Error updating bio: $e", context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> deleteListing(String listingId) async {
    try {
      await FirebaseFirestore.instance.collection('Listings').doc(listingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Listing deleted successfully")),
      );
    } catch (e) {
      displayMessageToUser("Error deleting listing: $e", context);
    }
  }

  void confirmDelete(String listingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing"),
        content: const Text("Are you sure you want to delete this listing?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteListing(listingId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(onPressed: signOut, icon: const Icon(Icons.logout))
        ],
      ),
      drawer: const MyDrawer(),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colorScheme.primary));
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final user = snapshot.data!.data();
              if (user == null) {
                return const Center(child: Text("User data not found"));
              }
              return ListView(
                children: [
                  // Profile Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: colorScheme.onPrimary,
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
                                color: colorScheme.inversePrimary,
                              ),
                            ),
                            // Email hidden for privacy.
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
                      style: TextStyle(fontSize: 16, color: colorScheme.inversePrimary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GestureDetector(
                      onTap: editBio,
                      child: Text(
                        "Edit Bio",
                        style: TextStyle(fontSize: 16, color: colorScheme.inversePrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "My Listings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Listings Section
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Listings')
                        .where('sellerId', isEqualTo: currentUser!.email)
                        .snapshots(),
                    builder: (context, listingSnapshot) {
                      if (listingSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                      }
                      if (!listingSnapshot.hasData || listingSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No listings found", style: TextStyle(color: colorScheme.inversePrimary)));
                      }
                      final listings = listingSnapshot.data!.docs;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          var listingData = listings[index].data() as Map<String, dynamic>;
                          String title = listingData['title'] ?? 'No Title';
                          String price = listingData['price'] != null
                              ? "£${listingData['price'].toString()}"
                              : '£0';
                          String imageUrl = '';
                          if (listingData.containsKey('imageUrls') &&
                              listingData['imageUrls'] is List &&
                              listingData['imageUrls'].isNotEmpty) {
                            imageUrl = listingData['imageUrls'][0];
                          }
                          return Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Listing Image
                                    Expanded(
                                      child: imageUrl.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(14),
                                            topRight: Radius.circular(14)),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(14),
                                              topRight: Radius.circular(14)),
                                        ),
                                        child: Center(child: Icon(Icons.image, size: 50)),
                                      ),
                                    ),
                                    // Title and Price
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        "£$price",
                                        style: const TextStyle(color: Colors.green, fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              // Delete button overlay
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Confirm deletion of listing
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Delete Listing"),
                                        content: const Text("Are you sure you want to delete this listing?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              FirebaseFirestore.instance.collection('Listings').doc(listings[index].id).delete();
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Listing deleted successfully")));
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
