import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WithdrawScreen extends StatefulWidget {
  @override
  _WithdrawScreenState createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _mpesaController = TextEditingController();
  int userCoins = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    var uid = FirebaseAuth.instance.currentUser!.uid;
    var doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      userCoins = doc.data()?['coins'] ?? 0;
      loading = false;
    });
  }

  Future<void> _requestWithdraw() async {
    if (_mpesaController.text.length != 10) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Enter valid M-Pesa: 07...')));
      return;
    }
    if (userCoins < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Need 1000 coins minimum! You have $userCoins')));
      return;
    }

    var uid = FirebaseAuth.instance.currentUser!.uid;
    var user = FirebaseAuth.instance.currentUser!;

    // Create withdrawal request
    await FirebaseFirestore.instance.collection('withdrawals').add({
      'uid': uid,
      'email': user.email,
      'mpesaNumber': _mpesaController.text.trim(),
      'coins': 1000,
      'kshAmount': 100, // 1000 coins = 100 KSH
      'status': 'pending', // pending, approved, paid
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Deduct coins immediately
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'coins': FieldValue.increment(-1000)});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Request sent! You will receive 100 KSH in 24hrs')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar:
          AppBar(title: Text('Withdraw'), backgroundColor: Color(0xFF6C63FF)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color(0xFF6C63FF),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Your Balance', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 8),
                    Text('$userCoins Coins',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                    Text('= ${userCoins ~/ 10} KSH',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('1000 Coins = 100 KSH',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _mpesaController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa Number',
                hintText: '07XXXXXXXX',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF)),
                onPressed: userCoins >= 1000 ? _requestWithdraw : null,
                child: Text('WITHDRAW 1000 COINS → 100 KSH',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
            Text('Minimum 1000 coins. Paid within 24hrs to your M-Pesa.',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
