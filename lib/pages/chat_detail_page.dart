import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(title: Text(message)),
  );
}


class ChatDetailPage extends StatefulWidget {
  final String conversationId;
  const ChatDetailPage({Key? key, required this.conversationId})
      : super(key: key);

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController messageController = TextEditingController();
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    initializeConversationIfNeeded();
  }


  Future<void> initializeConversationIfNeeded() async {
    if (widget.conversationId.trim().isEmpty) return;
    DocumentReference conversationRef = FirebaseFirestore.instance
        .collection('Chats')
        .doc(widget.conversationId);


    List<String> participants = widget.conversationId.split('_').skip(1).toList();

    await conversationRef.set({
      'lastUpdated': FieldValue.serverTimestamp(),
      'participants': participants,
    }, SetOptions(merge: true));
  }

  Future<void> sendMessage() async {
    String text = messageController.text.trim();
    if (text.isEmpty) {
      displayMessageToUser("Please enter a message", context);
      return;
    }
    setState(() {
      isSending = true;
    });
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ?? "unknown";
    try {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.conversationId)
          .collection('messages')
          .add({
        'sender': currentUserEmail,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Message sent")));
    } catch (e) {
      displayMessageToUser("Error sending message: $e", context);
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Widget buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}"));
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text("No messages yet."));
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            bool isMe = data['sender'] == FirebaseAuth.instance.currentUser?.email;
            DateTime messageTime = DateTime.now();
            if (data['timestamp'] is Timestamp) {
              messageTime = (data['timestamp'] as Timestamp).toDate();
            }
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['message'] ?? "",
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          isSending
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: sendMessage,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(child: buildMessageList()),
          buildMessageInput(),
        ],
      ),
    );
  }
}
