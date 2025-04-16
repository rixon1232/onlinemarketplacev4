// File: /lib/pages/my_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import '../helper/helper_functions.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController bioController = TextEditingController();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    if (currentUser == null) throw Exception('Not logged in');
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
  }

  Future<void> deleteListing(String listingId) async {
    await FirebaseFirestore.instance
        .collection('Listings')
        .doc(listingId)
        .delete();
  }

  void editBio() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Edit Bio"),
        content: TextField(
          controller: bioController,
          decoration: const InputDecoration(hintText: "Enter your bio"),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(currentUser!.email)
                    .update({'bio': bioController.text});
                bioController.clear();
                Navigator.of(ctx).pop();
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

  Future<void> deleteUserDocuments() async {
    final listingsQuery = await FirebaseFirestore.instance
        .collection('Listings')
        .where('sellerId', isEqualTo: currentUser?.email)
        .get();
    for (var doc in listingsQuery.docs) await doc.reference.delete();
    await FirebaseFirestore.instance.collection('Users').doc(currentUser?.email).delete();
  }

  Future<void> deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Delete Account"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ?? false;
    if (!confirm) return;
    try {
      await deleteUserDocuments();
      await currentUser!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login_or_register', (_) => false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account deleted.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login_or_register', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: cs.inversePrimary,
        actions: [IconButton(onPressed: signOut, icon: const Icon(Icons.logout))],
      ),
      drawer: const MyDrawer(),
      backgroundColor: cs.surface,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          if (!snap.hasData || snap.data?.data() == null) {
            return const Center(child: Text('User not found'));
          }
          final user = snap.data!.data()!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 40, backgroundColor: cs.primary, child: Icon(Icons.person, size: 40, color: cs.onPrimary)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['username'] ?? 'Username', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(user['bio'] ?? 'Add a bio.', style: TextStyle(color: cs.onBackground.withOpacity(0.7))),
                            ],
                          ),
                        ),
                        IconButton(onPressed: editBio, icon: const Icon(Icons.edit))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Listings
                Text('My Listings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onBackground)),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Listings')
                      .where('sellerId', isEqualTo: currentUser?.email)
                      .snapshots(),
                  builder: (context, lstSnap) {
                    if (!lstSnap.hasData) return const SizedBox();
                    final docs = lstSnap.data!.docs;
                    if (docs.isEmpty) return const Text('No listings');
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final d = doc.data();
                        final title = d['title'] ?? '';
                        final price = d['price'] != null ? '£${d['price']}' : '';
                        final img = (d['imageUrls'] as List?)?.first;
                        return Stack(
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: img != null
                                        ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(img, fit: BoxFit.cover),
                                    )
                                        : Container(color: Colors.grey.shade200),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(price, style: const TextStyle(color: Colors.green)),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () async {
                                  await deleteListing(doc.id);
                                  setState(() {});
                                },
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Reviews Section
                Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onBackground)),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(currentUser?.email)
                      .collection('Reviews')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, rvSnap) {
                    if (!rvSnap.hasData) return const SizedBox();
                    final revs = rvSnap.data!.docs;
                    if (revs.isEmpty) return const Text('No reviews yet');
                    return Column(
                      children: revs.map((doc) {
                        final r = doc.data();
                        final stars = r['rating'] as int;
                        final comment = r['comment'] ?? '';
                        final name = r['buyerName'] ?? r['buyerId'] as String;
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                        (i) => Icon(i < stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 18),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(comment),
                                const SizedBox(height: 6),
                                Text('– $name', style: TextStyle(fontStyle: FontStyle.italic, color: cs.onBackground.withOpacity(0.6))),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Delete Account Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    ),
                    onPressed: deleteAccount,
                    child: const Text('Delete Account', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
