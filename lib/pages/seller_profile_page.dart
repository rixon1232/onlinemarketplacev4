// File: /lib/pages/seller_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerEmail;
  const SellerProfilePage({super.key, required this.sellerEmail});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  Future<DocumentSnapshot<Map<String, dynamic>>> getSellerDetails() async {
    return FirebaseFirestore.instance.collection("Users").doc(widget.sellerEmail).get();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Profile"),
        backgroundColor: colorScheme.inversePrimary,
      ),
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getSellerDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: colorScheme.primary));
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return Center(child: Text("Seller data not found", style: TextStyle(color: colorScheme.onBackground)));
            }
            final seller = snapshot.data!.data();
            return ListView(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: Icon(Icons.person, size: 50, color: colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            seller!['username'] ?? "No Username",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
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
                    seller['bio'] ?? "No Bio Available",
                    style: TextStyle(fontSize: 16, color: colorScheme.onBackground),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Listings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Listings')
                      .where('sellerId', isEqualTo: widget.sellerEmail)
                      .snapshots(),
                  builder: (context, listingSnapshot) {
                    if (listingSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                    }
                    if (!listingSnapshot.hasData || listingSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No listings found", style: TextStyle(color: colorScheme.onBackground)));
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
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: imageUrl.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
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
                                      topRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.image, size: 50, color: colorScheme.onBackground),
                                  ),
                                ),
                              ),
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
                                  price,
                                  style: const TextStyle(color: Colors.green, fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
