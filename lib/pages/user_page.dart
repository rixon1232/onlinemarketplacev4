
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_drawer.dart';
import 'chat_detail_page.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Chats').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No conversations available"));
          }

          // Filter conversations where the current user is either buyer or seller.
          final chats = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['buyerId'] == currentUserEmail || data['sellerId'] == currentUserEmail;
          }).toList();

          if (chats.isEmpty) {
            return const Center(child: Text("No conversations available"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chatDoc = chats[index];
              var chatData = chatDoc.data() as Map<String, dynamic>;
              // Determine the other party's email.
              String otherPartyEmail = chatData['buyerId'] == currentUserEmail
                  ? chatData['sellerId']
                  : chatData['buyerId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Users').doc(otherPartyEmail).get(),
                builder: (context, userSnapshot) {
                  String otherPartyName = otherPartyEmail; // Fallback to email if no username.
                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.hasData &&
                      userSnapshot.data!.data() != null) {
                    var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    otherPartyName = userData['username'] ?? otherPartyEmail;
                  }
                  return ListTile(
                    title: Text("Chat with $otherPartyName"),
                    subtitle: chatData.containsKey('listingId')
                        ? Text("Listing: ${chatData['listingId']}")
                        : null,
                    onTap: () {
                      // Navigate to the ChatDetailPage passing the conversation document ID.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatDetailPage(conversationId: chatDoc.id),
                        ),
                      );
                    },
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
