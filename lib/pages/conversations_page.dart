import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_detail_page.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({Key? key}) : super(key: key);


  String getCurrentUserEmail() {
    return FirebaseAuth.instance.currentUser?.email ?? "unknown";
  }


  void navigateToProfile(BuildContext context, String userEmail, bool isSeller) {

    String routeName = isSeller ? '/buyer_profile' : '/seller_profile';

    Navigator.pushNamed(context, routeName, arguments: userEmail);
  }


  Future<void> deleteConversation(
      BuildContext context, DocumentReference conversationRef) async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Conversation"),

        content:
        const Text("Are you sure you want to delete this conversation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),

            child: const Text("Delete"),
          ),
        ],
      ),
    ) ??
        false;
    if (confirm) {
      try {
        await conversationRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Conversation deleted")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error deleting conversation: $e")));

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUser = getCurrentUserEmail();
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Conversations"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Chats')
            .where('participants', arrayContains: currentUser)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)

            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          final conversations = snapshot.data?.docs ?? [];
          if (conversations.isEmpty)
            return const Center(child: Text("No conversations found."));
          return ListView.separated(

            itemCount: conversations.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              final doc = conversations[index];
              final data = doc.data() as Map<String, dynamic>;
              final conversationId = doc.id;
              final productName = data['productName'] ?? "Product";
              final sellerId = data['sellerId'] ?? "unknown";
              final buyerId = data['buyerId'] ?? "unknown";
              final lastUpdated = data['lastUpdated'] as Timestamp?;

              String lastUpdatedStr = lastUpdated != null
                  ? DateTime.fromMillisecondsSinceEpoch(

                  lastUpdated.millisecondsSinceEpoch)
                  .toLocal()
                  .toString()
                  .split('.')[0]
                  : "";

              // Determine the other party:
              bool currentIsSeller = currentUser == sellerId;
              String otherParty = currentIsSeller ? buyerId : sellerId;
              String otherLabel =
              currentIsSeller ? "Buyer" : "Seller"; // label for link

              return ListTile(
                leading: Icon(Icons.chat,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(productName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Conversation: $conversationId"),
                    if (lastUpdatedStr.isNotEmpty)
                      Text("Last Updated: $lastUpdatedStr"),
                    Row(
                      children: [
                        Text("$otherLabel: ",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () => navigateToProfile(context, otherParty, currentIsSeller),
                          child: Text(otherParty,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteConversation(context, doc.reference),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatDetailPage(conversationId: conversationId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
