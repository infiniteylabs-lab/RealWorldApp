import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  String getChatId(String otherUserId) {
    String myId = currentUserId;
    return myId.hashCode <= otherUserId.hashCode
        ? '${myId}_$otherUserId'
        : '${otherUserId}_$myId';
  }

  Future<void> sendMessage(String otherUserId, String text) async {
    String chatId = getChatId(otherUserId);

    // Save message
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Save chat list for both users
    await _firestore.collection('chats').doc(chatId).set({
      'users': [currentUserId, otherUserId],
      'lastMessage': text,
      'lastTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getMessages(String otherUserId) {
    String chatId = getChatId(otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Stream<QuerySnapshot> getMyChats() {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: currentUserId)
        .orderBy('lastTime', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots();
  }
}
