import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLiveChat extends StatelessWidget {
  const AdminLiveChat({super.key});

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Chat', style: TextStyle(color: Colors.white)),
        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('support_chats')
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          final chatDocs = snapshot.data?.docs ?? [];

          // EMPTY STATE
          if (chatDocs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "No Live Chats Yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "When students contact support,\nconversations will appear here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }

          // CHAT LIST
          return ListView.separated(
            itemCount: chatDocs.length,

            separatorBuilder: (context, index) {
              return const Divider(height: 1);
            },

            itemBuilder: (context, index) {
              final data = chatDocs[index].data() as Map<String, dynamic>;

              // GET REAL STUDENT EMAIL
              final studentEmail = (data['studentEmail'] ?? 'Unknown Student')
                  .toString();

              final lastMessage = data['lastMessage'] ?? 'No messages yet';

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: fueRed,
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                title: Text(
                  studentEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),

                  child: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                trailing: const Icon(Icons.chevron_right, color: fueRed),

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) {
                        return AdminChatDetail(
                          chatId: chatDocs[index].id,
                          studentEmail: studentEmail,
                        );
                      },
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

class AdminChatDetail extends StatefulWidget {
  final String chatId;
  final String studentEmail;

  const AdminChatDetail({
    super.key,
    required this.chatId,
    required this.studentEmail,
  });

  @override
  State<AdminChatDetail> createState() => _AdminChatDetailState();
}

class _AdminChatDetailState extends State<AdminChatDetail> {
  final TextEditingController _messageController = TextEditingController();

  // SEND MESSAGE
  Future<void> _sendAdminReply() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    final msg = _messageController.text.trim();

    _messageController.clear();

    // SAVE MESSAGE
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'senderRole': 'admin',
          'senderRef': 'admin_account_id',
          'message': msg,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    // UPDATE PREVIEW
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.chatId)
        .update({
          'lastMessage': msg,
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
  }

  @override
  Widget build(BuildContext context) {
    const Color fueRed = Color(0xffb1170c);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.studentEmail,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),

        backgroundColor: fueRed,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // MESSAGES
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                // LOADING
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // EMPTY CHAT
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          "No messages yet",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // MESSAGES LIST
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),

                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index];

                    final isAdmin = data['senderRole'] == 'admin';

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),

                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),

                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),

                        decoration: BoxDecoration(
                          color: isAdmin ? fueRed : Colors.grey[200],

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Text(
                          data['message'].toString(),

                          style: TextStyle(
                            color: isAdmin ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // INPUT AREA
          Container(
            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(
              color: Colors.white,

              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),

            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,

                    decoration: const InputDecoration(
                      hintText: "Reply to student...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.send, color: fueRed),

                  onPressed: _sendAdminReply,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
