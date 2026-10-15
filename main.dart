import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'REALWORLD V3',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const CheckLogin(),
    );
  }
}

class CheckLogin extends StatefulWidget {
  const CheckLogin({super.key});
  @override
  State<CheckLogin> createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  _check() async {
    final p = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    if (p.getString('phone') != null)
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => Home(phone: p.getString('phone')!)));
    else
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
          body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.rocket_launch, size: 60, color: Colors.blue),
        SizedBox(height: 10),
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text("REALWORLD V3 Loading...")
      ])));
}

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final phone = TextEditingController(text: "0724236654");
  final email = TextEditingController(text: "inifinitey.labs@gmail.com");
  final otp = TextEditingController();
  bool sent = false;
  bool loading = false;
  String msg = "";
  void send() {
    setState(() {
      sent = true;
      msg = "OTP is 123456";
    });
  }

  Future<void> verify() async {
    if (otp.text != "123456") {
      setState(() => msg = "Wrong OTP! Use 123456");
      return;
    }
    setState(() => loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phone.text.trim())
          .set({
        'phone': phone.text.trim(),
        'email': email.text.trim(),
        'balance': 1000,
        'createdAt': FieldValue.serverTimestamp(),
        'app': 'REALWORLD V3 - inifinitey.labs@gmail.com'
      }, SetOptions(merge: true));
      final p = await SharedPreferences.getInstance();
      await p.setString('phone', phone.text.trim());
      await p.setString('email', email.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => Home(phone: phone.text.trim())));
    } catch (e) {
      setState(() => msg = "Error: $e");
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.rocket_launch, size: 70, color: Colors.blue),
                  const Text("REALWORLD V3",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const Text("Firebase: inifinitey.labs@gmail.com",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  TextField(
                      controller: phone,
                      decoration: const InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone))),
                  const SizedBox(height: 10),
                  TextField(
                      controller: email,
                      decoration: const InputDecoration(
                          labelText: "Email (Firebase Owner)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email))),
                  const SizedBox(height: 10),
                  if (sent)
                    TextField(
                        controller: otp,
                        decoration: const InputDecoration(
                            labelText: "OTP 123456",
                            border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  if (!sent)
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: send, child: const Text("SEND OTP"))),
                  if (sent)
                    SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: loading ? null : verify,
                            child: Text(loading
                                ? "Saving to Firebase..."
                                : "VERIFY & LOGIN"))),
                  const SizedBox(height: 10),
                  Text(msg,
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ]))));
  }
}

class Home extends StatefulWidget {
  final String phone;
  const Home({super.key, required this.phone});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int current = 0;
  final pages = [
    'Home',
    'Studio',
    'Market',
    'Wallet',
    'Learn',
    'Jobs',
    'Chat',
    'Services',
    'Profile'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pages[current]), centerTitle: true, actions: [
        IconButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.clear();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login()),
                    (_) => false);
            },
            icon: const Icon(Icons.logout))
      ]),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: current,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          onTap: (i) => setState(() => current = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.video_library), label: 'Studio'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Market'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.handyman), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ]),
    );
  }

  Widget _getPage() {
    if (current == 0)
      return HomeGrid(
          phone: widget.phone, onTap: (i) => setState(() => current = i));
    if (current == 1) return StudioPage(phone: widget.phone);
    if (current == 2) return MarketPage(phone: widget.phone);
    if (current == 3) return WalletPage(phone: widget.phone);
    if (current == 4) return const LearnPage();
    if (current == 5) return JobsPage(phone: widget.phone);
    if (current == 6) return ChatPage(phone: widget.phone);
    if (current == 7) return const ServicesPage();
    return ProfilePage(phone: widget.phone);
  }
}

class HomeGrid extends StatelessWidget {
  final String phone;
  final Function(int) onTap;
  const HomeGrid({super.key, required this.phone, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(phone)
              .snapshots(),
          builder: (c, s) {
            final bal = s.data?.data()?['balance'] ?? 1000;
            return Card(
                color: Colors.blue.shade50,
                child: ListTile(
                    leading: const Icon(Icons.verified_user,
                        color: Colors.green, size: 40),
                    title: Text("Hi, $phone"),
                    subtitle: Text(
                        "Balance: KES $bal | inifinitey.labs@gmail.com ✓")));
          }),
      const SizedBox(height: 10),
      GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          children: [
            _item("Studio", Icons.video_library, Colors.purple, 1),
            _item("Market", Icons.store, Colors.orange, 2),
            _item("Wallet", Icons.account_balance_wallet, Colors.green, 3),
            _item("Learn", Icons.school, Colors.indigo, 4),
            _item("Jobs", Icons.work, Colors.teal, 5),
            _item("Chat", Icons.chat, Colors.pink, 6),
            _item("Services", Icons.handyman, Colors.brown, 7),
            _item("Profile", Icons.person, Colors.red, 8),
          ])
    ]);
  }

  Widget _item(String n, IconData ic, Color c, int idx) {
    return InkWell(
        onTap: () => onTap(idx),
        child: Card(
            elevation: 3,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(ic, size: 40, color: c),
              const SizedBox(height: 8),
              Text(n, style: const TextStyle(fontWeight: FontWeight.bold))
            ])));
  }
}

class StudioPage extends StatelessWidget {
  final String phone;
  const StudioPage({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('studio').add({
                'phone': phone,
                'name': 'Video ${DateTime.now().second}',
                'createdAt': FieldValue.serverTimestamp()
              });
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('studio')
                .where('phone', isEqualTo: phone)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (c, s) {
              if (!s.hasData)
                return const Center(child: CircularProgressIndicator());
              if (s.data!.docs.isEmpty)
                return const Center(child: Text("No videos yet. Tap +"));
              return ListView(
                  children: s.data!.docs
                      .map((d) => ListTile(
                          leading: const Icon(Icons.video_file,
                              color: Colors.purple),
                          title: Text(d['name'])))
                      .toList());
            }));
  }
}

class MarketPage extends StatelessWidget {
  final String phone;
  const MarketPage({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').add({
                'name': 'Product ${DateTime.now().second}',
                'price': 500,
                'phone': phone,
                'createdAt': FieldValue.serverTimestamp()
              });
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (c, s) {
              if (!s.hasData)
                return const Center(child: CircularProgressIndicator());
              return ListView(
                  children: s.data!.docs
                      .map((d) => Card(
                          child: ListTile(
                              title: Text(d['name']),
                              subtitle: Text("KES ${d['price']}"),
                              trailing: ElevatedButton(
                                  onPressed: () async {
                                    final u = await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(phone)
                                        .get();
                                    final b = u.data()?['balance'] ?? 0;
                                    if (b >= d['price'])
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(phone)
                                          .update({'balance': b - d['price']});
                                  },
                                  child: const Text("Buy")))))
                      .toList());
            }));
  }
}

class WalletPage extends StatelessWidget {
  final String phone;
  const WalletPage({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(phone)
            .snapshots(),
        builder: (c, s) {
          final bal = s.data?.data()?['balance'] ?? 0;
          return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.account_balance_wallet,
                size: 80, color: Colors.green),
            Text("KES $bal",
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(phone)
                      .update({'balance': FieldValue.increment(1000)});
                },
                child: const Text("Add KES 1000"))
          ]));
        });
  }
}

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      ListTile(leading: Icon(Icons.school), title: Text("Flutter Mastery")),
      ListTile(leading: Icon(Icons.school), title: Text("Firebase 2026")),
      ListTile(leading: Icon(Icons.school), title: Text("M-Pesa API"))
    ]);
  }
}

class JobsPage extends StatelessWidget {
  final String phone;
  const JobsPage({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('jobs').add({
                'title': 'Job ${DateTime.now().second}',
                'pay': 20000,
                'phone': phone,
                'createdAt': FieldValue.serverTimestamp()
              });
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('jobs')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (c, s) {
              if (!s.hasData)
                return const Center(child: CircularProgressIndicator());
              return ListView(
                  children: s.data!.docs
                      .map((d) => Card(
                          child: ListTile(
                              title: Text(d['title']),
                              subtitle: Text("KES ${d['pay']}"),
                              trailing: ElevatedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('applications')
                                        .add({
                                      'jobId': d.id,
                                      'phone': phone,
                                      'createdAt': FieldValue.serverTimestamp()
                                    });
                                  },
                                  child: const Text("Apply")))))
                      .toList());
            }));
  }
}

class ChatPage extends StatefulWidget {
  final String phone;
  const ChatPage({super.key, required this.phone});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final c = TextEditingController();
  _send() async {
    if (c.text.trim().isEmpty) return;
    await FirebaseFirestore.instance.collection('chats').add({
      'phone': widget.phone,
      'msg': c.text.trim(),
      'createdAt': FieldValue.serverTimestamp()
    });
    c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('createdAt', descending: true)
                  .limit(50)
                  .snapshots(),
              builder: (c2, s) {
                if (!s.hasData)
                  return const Center(child: CircularProgressIndicator());
                return ListView(
                    reverse: true,
                    children: s.data!.docs
                        .map((d) => ListTile(
                            title: Text(d['phone']), subtitle: Text(d['msg'])))
                        .toList());
              })),
      Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
                child: TextField(
                    controller: c,
                    decoration: const InputDecoration(
                        hintText: "Message...", border: OutlineInputBorder()))),
            IconButton(onPressed: _send, icon: const Icon(Icons.send))
          ]))
    ]);
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      ListTile(title: Text("Phone Repair - KES 500")),
      ListTile(title: Text("Laptop Repair - KES 1500")),
      ListTile(title: Text("Design - KES 2000"))
    ]);
  }
}

class ProfilePage extends StatelessWidget {
  final String phone;
  const ProfilePage({super.key, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_done, size: 80, color: Colors.green),
      Text("Phone: $phone"),
      const Text("Owner: inifinitey.labs@gmail.com"),
      const Text("Firebase: realworld-2026 ✓"),
      const SizedBox(height: 20),
      ElevatedButton(
          onPressed: () async {
            final p = await SharedPreferences.getInstance();
            await p.clear();
            if (context.mounted)
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                  (_) => false);
          },
          child: const Text("Logout"))
    ]));
  }
}
