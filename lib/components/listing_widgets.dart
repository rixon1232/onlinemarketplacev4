import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../pages/listing_detail_page.dart'; // Ensure this imports your updated ListingDetailPage

class GridListingView extends StatelessWidget {
  final ColorScheme colorScheme;
  final String searchQuery;
  const GridListingView({Key? key, required this.colorScheme, this.searchQuery = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Listings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text("No Listings available",
                  style: TextStyle(color: colorScheme.onBackground)));
        }
        final listings = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? "";
          final description = data['description']?.toString().toLowerCase() ?? "";
          final query = searchQuery.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
        if (listings.isEmpty) {
          return Center(
              child: Text("No Listings match your search",
                  style: TextStyle(color: colorScheme.onBackground)));
        }
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
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
              return GestureDetector(
                onTap: () {
                  // Navigate to ListingDetailPage with both listingId and listingData.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListingDetailPage(
                        listingId: listings[index].id,
                        listingData: listingData,
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
                            child: Icon(Icons.image,
                                size: 50, color: colorScheme.onBackground),
                          ),
                        ),
                      ),
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
                          style: const TextStyle(
                              color: Colors.green, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ScrollListingView extends StatelessWidget {
  final ColorScheme colorScheme;
  final String searchQuery;
  const ScrollListingView({Key? key, required this.colorScheme, this.searchQuery = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Listings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text("No Listings available",
                  style: TextStyle(color: colorScheme.onBackground)));
        }
        final listings = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final title = data['title']?.toString().toLowerCase() ?? "";
          final description = data['description']?.toString().toLowerCase() ?? "";
          final query = searchQuery.toLowerCase();
          return title.contains(query) || description.contains(query);
        }).toList();
        if (listings.isEmpty) {
          return Center(
              child: Text("No Listings match your search",
                  style: TextStyle(color: colorScheme.onBackground)));
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: listings.length,
          itemBuilder: (context, index) {
            var listingData = listings[index].data() as Map<String, dynamic>;
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
                      listingId: listings[index].id,
                      listingData: listingData,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade800),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listingData['title'] ?? 'No Title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "£${listingData['price'].toString()}",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listingData['description'] ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
