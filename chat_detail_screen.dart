import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String otherUserId;
  final String otherEmail;
  ChatDetailScreen({required this.otherUserId, required this.otherEmail});
  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  final _chatService = ChatService();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    _chatService.sendMessage(widget.otherUserId, _controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.otherEmail), backgroundColor: Color(0xFF6C63FF)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.otherUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                var msgs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    var msg = msgs[i];
                    bool isMe = msg['senderId'] == _chatService.currentUserId;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF6C63FF) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg['text'],
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: 'Type message...',
                            border: OutlineInputBorder()))),
                IconButton(
                    icon: Icon(Icons.send, color: Color(0xFF6C63FF)),
                    onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
