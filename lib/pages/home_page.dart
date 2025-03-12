// File: /lib/pages/home_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketplaceappv4/components/my_drawer.dart';
import 'listing_detail_page.dart'; // Make sure this file exists
import 'add_listing.dart';         // Make sure this file exists

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.add_business_rounded,
              size: 32,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 10),
            const Text(
              'Marketplace',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const MyDrawer(),
      backgroundColor: colorScheme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Listings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No Listings available",
                style: TextStyle(color: colorScheme.onBackground),
              ),
            );
          }
          final listings = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Banner section before listings
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      "Just for you",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Listings grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // two columns for a marketplace look
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      var listingData = listings[index].data() as Map<String, dynamic>;
                      String title = listingData['title'] ?? 'No Title';
                      // Show price with the pound symbol (£)
                      String price = listingData['price'] != null
                          ? "£${listingData['price'].toString()}"
                          : '£0';
                      String imageUrl = '';
                      if (listingData.containsKey('imageUrls') &&
                          listingData['imageUrls'] is List &&
                          listingData['imageUrls'].isNotEmpty) {
                        imageUrl = listingData['imageUrls'][0];
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListingDetailPage(
                                listingData: listingData,
                                listingId: listings[index].id,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
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
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 50,
                                      color: colorScheme.onBackground,
                                    ),
                                  ),
                                ),
                              ),
                              // Listing Title and Price
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.onBackground),
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // Floating action button to add a new listing
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_listing');
        },
        child: Icon(Icons.add, color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
