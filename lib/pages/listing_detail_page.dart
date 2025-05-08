import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingDetailPage extends StatefulWidget {
  final Map<String, dynamic> listingData;

  final String listingId;

  const ListingDetailPage({
    Key? key,
    required this.listingData,

    required this.listingId,

  }) : super(key: key);

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {

  String getConversationId() {
    String buyerEmail = FirebaseAuth.instance.currentUser?.email ?? "unknown";

    String sellerEmail = widget.listingData['sellerId'] ?? "unknown";

    //
    String nonEmptyListingId =
    widget.listingId.trim().isEmpty ? "defaultListingId" : widget.listingId;
    List<String> participants = [buyerEmail, sellerEmail];
    participants.sort(); // Sorting ensures a consistent order.
    return "${nonEmptyListingId}_${participants.join('_')}";
  }


  Future<void> initializeConversation() async {
    final String buyerEmail = FirebaseAuth.instance.currentUser?.email ?? "unknown";
    final String sellerEmail = widget.listingData['sellerId'] ?? "unknown";
    final String conversationId = getConversationId();


    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(conversationId)
        .set({
      'productName': widget.listingData['title'] ?? "",
      'sellerId': sellerEmail,
      'buyerId': buyerEmail,
      'participants': [buyerEmail, sellerEmail],
      'lastUpdated': FieldValue.serverTimestamp(),
      'displayName': widget.listingData['title'] + " - " + sellerEmail,
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildProductDetails() {
    final colorScheme = Theme.of(context).colorScheme;
    DateTime datePosted =
        DateTime.tryParse(widget.listingData['createdAt'] ?? "") ?? DateTime.now();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: widget.listingData.containsKey('imageUrls') &&
                widget.listingData['imageUrls'] is List &&
                widget.listingData['imageUrls'].isNotEmpty
                ? Image.network(
              widget.listingData['imageUrls'][0],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              height: 250,
              color: Colors.grey.shade300,
              child: Center(
                child: Icon(Icons.image,
                    size: 80, color: colorScheme.onBackground),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.listingData['title'] ?? "No Title",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                    Text(
                      "£${widget.listingData['price'].toString()}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Posted Date
                Text(
                  "Posted on: ${datePosted.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(fontSize: 14, color: colorScheme.onBackground),
                ),
                const SizedBox(height: 16),
                // Description
                Text(

                  widget.listingData['description'] ?? "No description provided",
                  style: TextStyle(fontSize: 16, color: colorScheme.onBackground),
                ),
                const SizedBox(height: 16),
                // Seller Info
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(widget.listingData['sellerId'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                              color: colorScheme.primary));
                    }
                    if (!snapshot.hasData || snapshot.data?.data() == null) {
                      return Text("Seller: Unknown",
                          style: TextStyle(
                              fontSize: 16, color: colorScheme.onBackground));
                    }
                    Map<String, dynamic> sellerData =
                    snapshot.data!.data() as Map<String, dynamic>;
                    String sellerName =
                        sellerData['username'] ?? widget.listingData['sellerId'];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text("Seller: ",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          InkWell(
                            onTap: () {
                              // Navigate to seller profile page.
                              Navigator.pushNamed(
                                context,
                                '/seller_profile',
                                arguments: widget.listingData['sellerId'],
                              );
                            },
                            child: Text(
                              sellerName,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.primary,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Button to view the conversation for this listing.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () async {
                await initializeConversation();
                String conversationId = getConversationId();
                Navigator.pushNamed(context, '/chat_detail',
                    arguments: conversationId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text("View Conversation",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingData['title'] ?? "Listing Details"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: buildProductDetails(),
    );
  }
}

