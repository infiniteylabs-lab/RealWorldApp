import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class UsersListScreen extends StatelessWidget {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('New Chat'), backgroundColor: Color(0xFF6C63FF)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              var user = users[i];
              return ListTile(
                leading:
                    CircleAvatar(child: Text(user['email'][0].toUpperCase())),
                title: Text(user['email']),
                subtitle: Text('Tap to chat'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                              otherUserId: user['uid'],
                              otherEmail: user['email'],
                            ))),
              );
            },
          );
        },
      ),
    );
  }
}
