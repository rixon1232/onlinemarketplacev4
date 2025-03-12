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
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.sellerEmail)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Profile"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getSellerDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final seller = snapshot.data!.data();
              if (seller == null) {
                return const Center(child: Text("Seller data not found"));
              }
              return ListView(
                children: [
                  // Seller Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
                              seller['username'] ?? "No Username",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.inversePrimary),
                            ),
                            // Notice: We are NOT displaying the seller's email here.
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
                      style: TextStyle(
                          fontSize: 16, color: Theme.of(context).colorScheme.inversePrimary),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Listings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Seller's Listings (read-only)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Listings')
                        .where('sellerId', isEqualTo: widget.sellerEmail)
                        .snapshots(),
                    builder: (context, listingSnapshot) {
                      if (listingSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!listingSnapshot.hasData || listingSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No listings found"));
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
                              ? listingData['price'].toString()
                              : '0';
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
                                // Listing Image
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
                                    child: const Center(child: Icon(Icons.image, size: 50)),
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
                                    "\$$price",
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
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
      ),
    );
  }
}
