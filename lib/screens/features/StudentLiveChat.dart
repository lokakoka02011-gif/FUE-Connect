import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentLiveChat extends StatefulWidget {
  const StudentLiveChat({super.key});

  @override
  State<StudentLiveChat> createState() => _StudentLiveChatState();
}

class _StudentLiveChatState extends State<StudentLiveChat> {
  final TextEditingController _messageController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  late final String chatId;

  @override
  void initState() {
    super.initState();

    chatId = user!.uid;

    _createChatIfNeeded();
  }

  Future<void> _createChatIfNeeded() async {

    final chatRef =
        FirebaseFirestore.instance
            .collection('support_chats')
            .doc(chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {

      await chatRef.set({

        'studentId': user!.uid,

        'studentEmail': user!.email,

        'lastMessage': '',

        'lastMessageTime':
            FieldValue.serverTimestamp(),

        'isReadByAdmin': true,
      });
    }
  }
  Future<void> _sendMessage() async {
    if (user == null) return;
    if (_messageController.text.trim().isEmpty) return;

    final msg = _messageController.text.trim();

    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderRole': 'student',
          'senderRef': user!.uid,
          'message': msg,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(chatId)
        .update({
          'lastMessage': msg,
          'lastMessageTime': FieldValue.serverTimestamp(),

          'isReadByAdmin': false,
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Support")),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  reverse: true,

                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index];

                    final isStudent = data['senderRole'] == 'student';

                    return Align(
                      alignment: isStudent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: isStudent ? Colors.red : Colors.grey[300],

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Text(
                          data['message'].toString(),

                          style: TextStyle(
                            color: isStudent ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,

                    decoration: const InputDecoration(
                      hintText: "Type message...",
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _sendMessage,

                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
