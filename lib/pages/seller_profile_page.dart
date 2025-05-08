// File: /lib/pages/seller_profile_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerEmail;
  const SellerProfilePage({Key? key, required this.sellerEmail}) : super(key: key);

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {

  Future<DocumentSnapshot<Map<String, dynamic>>> getSellerDetails() async {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.sellerEmail)
        .get();
  }


  Future<void> submitReview(int rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final buyerSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();
    final buyerName = buyerSnapshot.data()?['username'] ?? user.email;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.sellerEmail)
        .collection('Reviews')
        .add({
      'buyerId': user.email,
      'buyerName': buyerName,
      'rating': rating,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  void showReviewDialog() {
    final commentController = TextEditingController();
    int tempRating = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < tempRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => tempRating = i + 1),
                  );
                }),
              ),
              TextField(
                controller: commentController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Leave a comment',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                if (tempRating > 0) {
                  await submitReview(tempRating, commentController.text.trim());
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isSeller = currentUser?.email == widget.sellerEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Profile'),
        backgroundColor: cs.inversePrimary,
      ),
      backgroundColor: cs.background,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getSellerDetails(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.data() == null) {
            return const Center(child: Text('Seller not found'));
          }
          final seller = snap.data!.data()!;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              // Seller info card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: cs.primary,
                        child: Icon(Icons.person, size: 36, color: cs.onPrimary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              seller['username'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              seller['bio'] ?? '',
                              style: TextStyle(color: cs.onBackground.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Listings section
              Text('Listings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onBackground)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Listings')
                      .where('sellerId', isEqualTo: widget.sellerEmail)
                      .snapshots(),
                  builder: (context, lstSnap) {
                    if (!lstSnap.hasData) return const SizedBox();
                    final docs = lstSnap.data!.docs;
                    if (docs.isEmpty) return const Text('No listings available');
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final d = docs[i].data();
                        final title = d['title'] ?? '';
                        final price = d['price'] != null ? '£${d['price']}' : '';
                        final img = (d['imageUrls'] as List?)?.first;
                        return SizedBox(
                          width: 160,
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (img != null)
                                  ClipRRect(

                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(img, height: 120, width: 160, fit: BoxFit.cover),
                                  ),
                                Padding(

                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(title, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(

                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(price, style: const TextStyle(color: Colors.green)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Write Review button
              if (!isSeller)
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Write a Review'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: showReviewDialog,
                  ),
                ),
              const SizedBox(height: 24),
              // Reviews section
              Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onBackground)),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.sellerEmail)
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
                      final name = r['buyerName'] ?? '';
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < stars ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Text(comment),
                              const SizedBox(height: 8),
                              Text('– $name', style: TextStyle(fontStyle: FontStyle.italic, color: cs.onBackground.withOpacity(0.7))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

