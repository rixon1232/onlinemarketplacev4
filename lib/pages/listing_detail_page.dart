
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingDetailPage extends StatefulWidget {
  final Map<String, dynamic> listingData;
  final String listingId; // Firestore document ID for the listing

  const ListingDetailPage({
    super.key,
    required this.listingData,
    required this.listingId,
  });

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  // Generate a conversation ID using listingId and buyer email.
  String getConversationId() {
    String buyer = FirebaseAuth.instance.currentUser?.email ?? "unknown";
    return "${widget.listingId}_$buyer";
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    setState(() {
      isSending = true;
    });
    String conversationId = getConversationId();
    String sellerId = widget.listingData['sellerId'] ?? "unknown";
    try {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(conversationId)
          .collection('messages')
          .add({
        'sender': FirebaseAuth.instance.currentUser?.email ?? "unknown",
        'message': messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'sellerId': sellerId,
        'buyerId': FirebaseAuth.instance.currentUser?.email ?? "unknown",
      });
      messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message sent")),
      );
    } catch (e) {
      // Optionally, use a helper function to show error messages.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message: $e")),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert stored date (ISO string) back to DateTime
    DateTime datePosted = DateTime.tryParse(widget.listingData['createdAt'] ?? "") ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listingData['title'] ?? 'Listing Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Listing image and details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display main image
                    widget.listingData.containsKey('imageUrls') &&
                        widget.listingData['imageUrls'] is List &&
                        widget.listingData['imageUrls'].isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.listingData['imageUrls'][0],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.listingData['title'] ?? 'No Title',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.listingData['description'] ?? 'No Description',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Price: \$${widget.listingData['price'].toString()}",
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Posted on: ${datePosted.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Seller info section
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(widget.listingData['sellerId'])
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (!snapshot.hasData || snapshot.data!.data() == null) {
                          return const Text("Seller: Unknown");
                        }
                        Map<String, dynamic> sellerData =
                        snapshot.data!.data() as Map<String, dynamic>;
                        String sellerName = sellerData['username'] ?? widget.listingData['sellerId'];
                        return Row(
                          children: [
                            const Text("Seller: "),
                            InkWell(
                              onTap: () {
                                // Navigate to SellerProfilePage using the seller's email.
                                Navigator.pushNamed(
                                  context,
                                  '/seller_profile',
                                  arguments: widget.listingData['sellerId'],
                                );
                              },
                              child: Text(
                                sellerName,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Message box at bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isSending
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: sendMessage,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

