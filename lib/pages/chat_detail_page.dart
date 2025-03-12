// File: /lib/pages/chat_detail_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../helper/helper_functions.dart';

class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  const ChatDetailPage({super.key, required this.conversationId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      displayMessageToUser("Please enter a message", context);
      return;
    }
    setState(() {
      isSending = true;
    });
    try {
      // Debug: print the conversationId and message to be sent
      print("Sending message to conversation: ${widget.conversationId}");
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'sender': FirebaseAuth.instance.currentUser?.email ?? "unknown",
        'message': messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
    } catch (e) {
      displayMessageToUser("Error sending message: $e", context);
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug: log that the ChatDetailPage is opened with the correct conversationId
    print("Opened ChatDetailPage for conversation: ${widget.conversationId}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                // Debug: print snapshot data to the console
                print("Snapshot docs: ${snapshot.data?.docs}");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData =
                    messages[index].data() as Map<String, dynamic>;
                    bool isMe = messageData['sender'] ==
                        FirebaseAuth.instance.currentUser?.email;
                    return Container(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(messageData['message'] ?? ""),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    hintText: "Type a message...",
                    obscureText: false,
                    controller: messageController,
                  ),
                ),
                const SizedBox(width: 8),
                isSending
                    ? const CircularProgressIndicator()
                    : MyButton(
                  text: "Send",
                  onTap: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

