import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- MAIN CHAT LIST (WhatsApp Style) ---
class AdminLiveChat extends StatelessWidget {
  const AdminLiveChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Inquiries', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // STEP 1: Using "support_chats" and ordering by "lastMessageTime"
        stream: FirebaseFirestore.instance
            .collection('support_chats')
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var chatDocs = snapshot.data!.docs;
            if (chatDocs.isEmpty) {
              return const Center(
                child: Text(
                  "No student inquiries yet",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

          return ListView.separated(
            itemCount: chatDocs.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              var data = chatDocs[index].data() as Map<String, dynamic>;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red, 
                  child: Icon(Icons.person, color: Colors.white)
                ),
                // Displaying student email from 'userRef'
                title: Text((data['userRef'] ?? 'Unknown Student').toString(),
                style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['lastMessage'] ?? 'No messages yet', maxLines: 1),
                trailing: Icon(Icons.chevron_right, color: Colors.red),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminChatDetail(
                        chatId: chatDocs[index].id,
                        studentEmail: data['userRef'] ?? 'Unknown Student',
                      ),
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

// --- CHAT DETAIL SCREEN ---
class AdminChatDetail extends StatefulWidget {
  final String chatId;
  final String studentEmail;

  const AdminChatDetail({
    super.key,
    required this.chatId,
    required this.studentEmail,
  });
  @override
  _AdminChatDetailState createState() => _AdminChatDetailState();
}

class _AdminChatDetailState extends State<AdminChatDetail> {
  final TextEditingController _messageController = TextEditingController();

  void _sendAdminReply() async {
    if (_messageController.text.trim().isEmpty) return;
    
    String msg = _messageController.text.trim();
    _messageController.clear();

    // STEP 2 & 4: Save message in subcollection "messages"
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderRole': 'admin', 
      'senderRef': 'admin_account_id', // TODO: Team Leader - replace with actual admin ID
      'message': msg,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // STEP 4: Update the parent document for the "WhatsApp List" preview
    await FirebaseFirestore.instance.collection('support_chats').doc(widget.chatId).update({
      'lastMessage': msg,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentEmail, style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.red[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    bool isAdmin = data['senderRole'] == 'admin';
                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.red[700] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          data['message'].toString(), 
                          style: TextStyle(color: isAdmin ? Colors.white : Colors.black)
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Input Field area
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: "Reply to student...", border: InputBorder.none),
                  ),
                ),
                IconButton(icon: Icon(Icons.send, color: Colors.red), onPressed: _sendAdminReply),
              ],
            ),
          ),
        ],
      ),
    );
  }
}