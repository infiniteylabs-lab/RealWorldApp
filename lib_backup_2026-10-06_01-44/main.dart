import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color appBackground = Color(0xFF0A0F1E);
const Color cardBackground = Color(0xFF131A2E);
const Color greenAccent = Color(0xFF4ADE80);

void main() => runApp(const RealWorldSuperApp());

class RealWorldSuperApp extends StatelessWidget {
  const RealWorldSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: appBackground,
        cardColor: cardBackground,
        colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: greenAccent,
              secondary: greenAccent,
              surface: cardBackground,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _loggedIn = false;
  String _username = 'Dragon';
  int _avatarIndex = 0;
  int _authStep = 0;

  @override
  void initState() {
    super.initState();
    _loadLogin();
  }

  Future<void> _loadLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _loggedIn = prefs.getBool('logged_in') ?? false;
      _username = prefs.getString('username') ?? 'Dragon';
      _avatarIndex = prefs.getInt('avatar_index') ?? 0;
      _loading = false;
    });
  }

  Future<void> _finishLogin(String username, int avatarIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    await prefs.setString('username', username);
    await prefs.setInt('avatar_index', avatarIndex);
    if (!mounted) return;
    setState(() {
      _loggedIn = true;
      _username = username;
      _avatarIndex = avatarIndex;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    if (mounted) setState(() => _loggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: greenAccent)),
      );
    }
    if (_loggedIn) {
      return MainNav(
        username: _username,
        avatarIndex: _avatarIndex,
        onLogout: _logout,
      );
    }
    if (_authStep == 0) {
      return SplashScreen(onContinue: () => setState(() => _authStep = 1));
    }
    if (_authStep == 1) {
      return LoginScreen(onVerified: () => setState(() => _authStep = 2));
    }
    return CreateProfileScreen(onComplete: _finishLogin);
  }
}

class SplashScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const SplashScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: greenAccent,
                  child: Icon(Icons.public, color: appBackground, size: 48),
                ),
                const SizedBox(height: 22),
                const Text(
                  'RealWorld',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your world. Your people. Your stories.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: greenAccent,
                      foregroundColor: appBackground,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Get started'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onVerified;

  const LoginScreen({super.key, required this.onVerified});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_phoneController.text.trim().length < 7) {
      _showMessage(context, 'Enter a valid phone number to continue.');
      return;
    }
    setState(() => _otpSent = true);
    _showMessage(context, 'Mock OTP sent. Use 123456 to continue.');
  }

  void _verify() {
    if (_otpController.text.trim() != '123456') {
      _showMessage(
          context, 'That code did not match. Try the mock code 123456.');
      return;
    }
    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.phone_android, size: 54, color: greenAccent),
          const SizedBox(height: 18),
          const Text(
            'Welcome back',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sign in with your phone number. This demo uses a mock OTP.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              prefixIcon: Icon(Icons.call_outlined),
              hintText: '+254 700 000 000',
            ),
          ),
          if (_otpSent) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'One-time code',
                prefixIcon: Icon(Icons.lock_outline),
                hintText: '123456',
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _otpSent ? _verify : _sendCode,
            style: FilledButton.styleFrom(
              backgroundColor: greenAccent,
              foregroundColor: appBackground,
              padding: const EdgeInsets.all(16),
            ),
            child: Text(_otpSent ? 'Verify code' : 'Send code'),
          ),
        ],
      ),
    );
  }
}

class CreateProfileScreen extends StatefulWidget {
  final Future<void> Function(String username, int avatarIndex) onComplete;

  const CreateProfileScreen({super.key, required this.onComplete});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController(text: 'Dragon');
  int _avatarIndex = 0;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage(context, 'Choose a username to continue.');
      return;
    }
    setState(() => _saving = true);
    await widget.onComplete(name, _avatarIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 30),
          Center(
            child: GestureDetector(
              onTap: () async {
                final selected = await showDialog<int>(
                  context: context,
                  builder: (_) => AvatarPicker(selected: _avatarIndex),
                );
                if (selected != null) setState(() => _avatarIndex = selected);
              },
              child: ProfileAvatar(index: _avatarIndex, radius: 48),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text('Tap to choose an avatar',
                  style: TextStyle(color: Colors.white60)),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _create,
            style: FilledButton.styleFrom(
              backgroundColor: greenAccent,
              foregroundColor: appBackground,
              padding: const EdgeInsets.all(16),
            ),
            child:
                Text(_saving ? 'Creating profile...' : 'Continue to RealWorld'),
          ),
        ],
      ),
    );
  }
}

class AvatarPicker extends StatelessWidget {
  final int selected;

  const AvatarPicker({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose an avatar'),
      content: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: List.generate(
          8,
          (index) => GestureDetector(
            onTap: () => Navigator.pop(context, index),
            child: Container(
              padding: EdgeInsets.all(index == selected ? 3 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: index == selected
                    ? Border.all(color: greenAccent, width: 2)
                    : null,
              ),
              child: ProfileAvatar(index: index, radius: 25),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final int index;
  final double radius;

  const ProfileAvatar({super.key, required this.index, required this.radius});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF2563EB),
      Color(0xFF9333EA),
      Color(0xFFEA580C),
      Color(0xFF0D9488),
      Color(0xFFDB2777),
      Color(0xFF65A30D),
      Color(0xFF4F46E5),
      Color(0xFFB45309),
    ];
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors[index % colors.length],
      child: Icon(Icons.person, color: Colors.white, size: radius),
    );
  }
}

class DownloadItem {
  final int id;
  final String title;
  final String size;
  final int colorIndex;
  double progress;

  DownloadItem({
    required this.id,
    required this.title,
    required this.size,
    required this.colorIndex,
    this.progress = 0,
  });
}

class MainNav extends StatefulWidget {
  final String username;
  final int avatarIndex;
  final Future<void> Function() onLogout;

  const MainNav({
    super.key,
    required this.username,
    required this.avatarIndex,
    required this.onLogout,
  });

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;
  int _downloadId = 0;
  final List<DownloadItem> _downloads = [];
  final Map<int, Timer> _downloadTimers = {};

  @override
  void dispose() {
    for (final timer in _downloadTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _startDownload(String title, int colorIndex) {
    final item = DownloadItem(
      id: ++_downloadId,
      title: title,
      size: '${(42 + colorIndex * 13) % 120 + 35} MB',
      colorIndex: colorIndex,
    );
    setState(() => _downloads.insert(0, item));
    _downloadTimers[item.id] = Timer.periodic(
      const Duration(milliseconds: 180),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          item.progress = (item.progress + 0.08).clamp(0, 1);
          if (item.progress >= 1) {
            timer.cancel();
            _downloadTimers.remove(item.id);
          }
        });
      },
    );
    _showMessage(context, 'Downloading $title');
  }

  void _deleteDownload(int id) {
    _downloadTimers.remove(id)?.cancel();
    setState(() => _downloads.removeWhere((item) => item.id == id));
  }

  void _openWatch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WatchScreen(onDownload: _startDownload),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          username: widget.username,
          avatarIndex: widget.avatarIndex,
          onLogout: () async {
            Navigator.of(context).popUntil((route) => route.isFirst);
            await widget.onLogout();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeFeed(),
      ExploreScreen(
        onOpenWatch: _openWatch,
        onOpenReels: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReelsScreen(onDownload: _startDownload),
          ),
        ),
      ),
      const CreatePostScreen(),
      const RealChatScreen(),
      const WalletScreen(),
      ProfileScreen(
        username: widget.username,
        avatarIndex: widget.avatarIndex,
        downloads: _downloads,
        onDeleteDownload: _deleteDownload,
        onDownload: _startDownload,
        onSettings: _openSettings,
        onAdmin: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ModerationPanel()),
        ),
      ),
    ];
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appBackground,
        selectedItemColor: greenAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _index = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'RealChat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  int _refreshCount = 0;
  Set<int> _likedPosts = {};
  Set<int> _savedPosts = {};
  List<int> _likeCounts = [318, 1200, 204];
  List<int> _commentCounts = [42, 86, 19];
  List<int> _shareCounts = [13, 28, 7];

  @override
  void initState() {
    super.initState();
    _loadHomeState();
  }

  Future<void> _loadHomeState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final liked = prefs.getStringList('home_liked_posts') ?? const [];
      _likedPosts = liked.map(int.parse).toSet();

      final saved = prefs.getStringList('home_saved_posts') ?? const [];
      _savedPosts = saved.map(int.parse).toSet();

      final likes = prefs.getStringList('home_like_counts');
      if (likes != null && likes.isNotEmpty) {
        _likeCounts = likes.map(int.parse).toList();
      }

      final comments = prefs.getStringList('home_comment_counts');
      if (comments != null && comments.isNotEmpty) {
        _commentCounts = comments.map(int.parse).toList();
      }

      final shares = prefs.getStringList('home_share_counts');
      if (shares != null && shares.isNotEmpty) {
        _shareCounts = shares.map(int.parse).toList();
      }
    });
  }

  Future<void> _saveHomeState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'home_liked_posts',
      _likedPosts.map((value) => value.toString()).toList(),
    );
    await prefs.setStringList(
      'home_saved_posts',
      _savedPosts.map((value) => value.toString()).toList(),
    );
    await prefs.setStringList(
      'home_like_counts',
      _likeCounts.map((value) => value.toString()).toList(),
    );
    await prefs.setStringList(
      'home_comment_counts',
      _commentCounts.map((value) => value.toString()).toList(),
    );
    await prefs.setStringList(
      'home_share_counts',
      _shareCounts.map((value) => value.toString()).toList(),
    );
  }

  Future<void> _toggleLike(int index) async {
    setState(() {
      if (_likedPosts.remove(index)) {
        _likeCounts[index]--;
      } else {
        _likedPosts.add(index);
        _likeCounts[index]++;
      }
    });
    await _saveHomeState();
  }

  Future<void> _addComment(int index, String postTitle) async {
    final localContext = context;
    final value = await showDialog<String>(
      context: localContext,
      builder: (dialogContext) => _CommentDialog(
        postTitle: postTitle,
        onSubmit: (text) => Navigator.pop(dialogContext, text),
      ),
    );
    if (value == null || value.trim().isEmpty || !mounted) return;
    setState(() => _commentCounts[index]++);
    await _saveHomeState();
    if (!localContext.mounted) return;
    _showMessage(localContext, 'Comment added.');
  }

  Future<void> _sharePost(int index) async {
    final localContext = context;
    setState(() => _shareCounts[index]++);
    await _saveHomeState();
    if (!localContext.mounted) return;
    _showMessage(localContext, 'Post link copied.');
  }

  Future<void> _toggleSave(int index) async {
    final localContext = context;
    setState(() {
      if (!_savedPosts.add(index)) _savedPosts.remove(index);
    });
    await _saveHomeState();
    if (!localContext.mounted) return;
    _showMessage(
      localContext,
      _savedPosts.contains(index) ? 'Post saved.' : 'Post removed from saved.',
    );
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _refreshCount++);
  }

  @override
  Widget build(BuildContext context) {
    final posts = [
      (
        'Power outage update',
        'Nairobi CBD',
        '2 min ago',
        '318',
        '42',
        Icons.bolt
      ),
      (
        'Sunset from the rooftop',
        'Kutus, Kenya',
        '18 min ago',
        '1.2k',
        '86',
        Icons.wb_twilight
      ),
      (
        'Weekend market finds',
        'Nyeri Town',
        '1 hr ago',
        '204',
        '19',
        Icons.storefront
      ),
    ];
    return SafeArea(
      child: RefreshIndicator(
        color: greenAccent,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'RealWorld',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      _showMessage(context, 'You are all caught up!'),
                  icon: const Icon(Icons.notifications_none),
                ),
                IconButton(
                  onPressed: () =>
                      _showMessage(context, 'Search is coming soon.'),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            if (_refreshCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Feed refreshed • update $_refreshCount',
                  style: const TextStyle(color: greenAccent, fontSize: 12),
                ),
              ),
            SizedBox(
              height: 112,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _StoryItem(name: 'Your story', icon: Icons.add, own: true),
                  _StoryItem(name: 'Amina', color: Color(0xFF9333EA)),
                  _StoryItem(name: 'Kevin', color: Color(0xFFEA580C)),
                  _StoryItem(name: 'Njeri', color: Color(0xFF0D9488)),
                  _StoryItem(name: 'Malik', color: Color(0xFFDB2777)),
                  _StoryItem(name: 'Wanjiku', color: Color(0xFF2563EB)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < posts.length; i++)
              _FeedPost(
                index: i,
                data: posts[i],
                liked: _likedPosts.contains(i),
                saved: _savedPosts.contains(i),
                likeCount: _likeCounts[i],
                commentCount: _commentCounts[i],
                shareCount: _shareCounts[i],
                onLike: () => _toggleLike(i),
                onComment: () => _addComment(i, posts[i].$1),
                onShare: () => _sharePost(i),
                onSave: () => _toggleSave(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final String name;
  final IconData? icon;
  final Color color;
  final bool own;

  const _StoryItem({
    required this.name,
    this.icon,
    this.color = greenAccent,
    this.own = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: own ? Colors.white24 : greenAccent, width: 2),
            ),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: color.withOpacity(0.22),
              child: Icon(icon ?? Icons.person, color: color, size: 27),
            ),
          ),
          const SizedBox(height: 6),
          Text(name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _FeedPost extends StatelessWidget {
  final int index;
  final (String, String, String, String, String, IconData) data;
  final bool liked;
  final bool saved;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const _FeedPost({
    required this.index,
    required this.data,
    required this.liked,
    required this.saved,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final shades = [
      const [Color(0xFF123A37), Color(0xFF1D273F)],
      const [Color(0xFF462C4D), Color(0xFF192D48)],
      const [Color(0xFF47341F), Color(0xFF1C2944)],
    ];
    return Card(
      color: cardBackground,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: greenAccent.withOpacity(.18),
              child: const Icon(Icons.person, color: greenAccent),
            ),
            title: Text(
                index == 0 ? 'Anon_2314' : 'RealWorld creator ${index + 1}'),
            subtitle: Row(
              children: [
                const Icon(Icons.location_on, size: 13, color: greenAccent),
                const SizedBox(width: 3),
                Text(data.$2, style: const TextStyle(fontSize: 12)),
              ],
            ),
            trailing: Text(data.$3,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(data.$1,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: shades[index % shades.length],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(data.$6, color: Colors.white.withOpacity(.22), size: 92),
                const Positioned(
                  bottom: 12,
                  right: 14,
                  child:
                      Icon(Icons.photo_camera_outlined, color: Colors.white70),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.pinkAccent : Colors.white),
              ),
              Text(_compactCount(likeCount)),
              IconButton(
                  onPressed: onComment,
                  icon: const Icon(Icons.mode_comment_outlined)),
              Text(_compactCount(commentCount)),
              IconButton(
                  onPressed: onShare, icon: const Icon(Icons.share_outlined)),
              Text(_compactCount(shareCount)),
              const Spacer(),
              IconButton(
                onPressed: onSave,
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                color: saved ? greenAccent : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _compactCount(int count) =>
    count >= 1000 ? '${(count / 1000).toStringAsFixed(1)}k' : '$count';

class _CommentDialog extends StatefulWidget {
  final String postTitle;
  final ValueChanged<String> onSubmit;

  const _CommentDialog({
    required this.postTitle,
    required this.onSubmit,
  });

  @override
  State<_CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<_CommentDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.postTitle, style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 280,
            decoration: const InputDecoration(hintText: 'Write a comment...'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final comment = _controller.text.trim();
            if (comment.isNotEmpty) widget.onSubmit(comment);
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}

class ExploreItem {
  final String title;
  final String creator;
  final bool video;
  final int colorIndex;
  final bool nearby;

  const ExploreItem(
    this.title,
    this.creator,
    this.video,
    this.colorIndex, {
    this.nearby = true,
  });
}

const List<ExploreItem> exploreItems = [
  ExploreItem('Morning light', 'Amina', false, 0),
  ExploreItem('City in motion', 'Kevin', true, 1, nearby: false),
  ExploreItem('Quiet corners', 'Njeri', false, 2),
  ExploreItem('Coastline', 'Malik', false, 3, nearby: false),
  ExploreItem('Street food tour', 'Wanjiku', true, 4),
  ExploreItem('Green escape', 'Lena', false, 5),
  ExploreItem('Night market', 'Juma', true, 2, nearby: false),
  ExploreItem('Weekend hike', 'Asha', false, 0),
  ExploreItem('New perspective', 'Timo', false, 4),
];

class ExploreScreen extends StatefulWidget {
  final VoidCallback onOpenWatch;
  final VoidCallback onOpenReels;

  const ExploreScreen({
    super.key,
    required this.onOpenWatch,
    required this.onOpenReels,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  final List<String> _filters = ['All', 'Pictures', 'Videos', 'Nearby'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final filtered = exploreItems.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(query) ||
          item.creator.toLowerCase().contains(query);
      final matchesType = _filter == 'All' ||
          (_filter == 'Nearby' && item.nearby) ||
          (_filter == 'Videos' && item.video) ||
          (_filter == 'Pictures' && !item.video);
      return matchesSearch && matchesType;
    }).toList();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Explore',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900)),
                      ),
                      TextButton.icon(
                        onPressed: widget.onOpenWatch,
                        icon: const Icon(Icons.movie_outlined),
                        label: const Text('Watch'),
                      ),
                      IconButton(
                        tooltip: 'Reels',
                        onPressed: widget.onOpenReels,
                        icon: const Icon(Icons.video_library_outlined,
                            color: greenAccent),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search people, places and posts',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final filter in _filters)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: filter == _filter,
                              selectedColor: greenAccent.withOpacity(.24),
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                  child: Text('No posts found. Try a different search.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    return _ExploreTile(
                      item: item,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExploreDetailScreen(item: item),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                  childAspectRatio: .76,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExploreTile extends StatelessWidget {
  final ExploreItem item;
  final VoidCallback onTap;

  const _ExploreTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Artwork(
              index: item.colorIndex,
              child: Icon(
                item.video ? Icons.movie_outlined : Icons.landscape_outlined,
                size: 38,
                color: Colors.white.withOpacity(.52),
              )),
          if (item.video)
            const Positioned(
              top: 6,
              right: 6,
              child:
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
          Positioned(
            left: 7,
            right: 5,
            bottom: 7,
            child: Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Colors.black87, blurRadius: 6),
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreDetailScreen extends StatelessWidget {
  final ExploreItem item;

  const ExploreDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: ListView(
        children: [
          SizedBox(
            height: 420,
            child: _Artwork(
              index: item.colorIndex,
              child: Icon(
                  item.video ? Icons.play_circle_outline : Icons.landscape,
                  size: 100,
                  color: Colors.white54),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(item.creator),
            subtitle:
                Text(item.video ? 'Video • 0:38' : 'Picture • 4 hours ago'),
            trailing: const Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
                '${item.title} • A moment shared with the RealWorld community.'),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: () => _showMessage(context, 'Liked.'),
                  icon: const Icon(Icons.favorite_border)),
              IconButton(
                  onPressed: () => _showMessage(context, 'Comments opened.'),
                  icon: const Icon(Icons.mode_comment_outlined)),
              IconButton(
                  onPressed: () => _showMessage(context, 'Link copied.'),
                  icon: const Icon(Icons.share_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}

class WatchTitle {
  final String title;
  final String rating;
  final int colorIndex;
  final bool series;
  final String description;

  const WatchTitle(
      this.title, this.rating, this.colorIndex, this.series, this.description);
}

const List<WatchTitle> watchTitles = [
  WatchTitle('The Long Road', '8.8', 0, true,
      'A young journalist returns home to uncover a story that changes her community.'),
  WatchTitle('Small Town Stories', '8.2', 2, true,
      'Three neighbors find unexpected friendship as their town begins to change.'),
  WatchTitle('After the Rain', '7.9', 4, true,
      'A family rebuilds its life and discovers hope after a difficult season.'),
  WatchTitle('Beyond the Valley', '9.1', 1, false,
      'An inspiring journey through the landscapes and people of East Africa.'),
  WatchTitle('One More Sunday', '7.6', 3, false,
      'A warm-hearted comedy about family, food and coming home.'),
  WatchTitle('The Last Signal', '8.4', 5, false,
      'A radio host races to reconnect a remote village during a storm.'),
];

class WatchScreen extends StatelessWidget {
  final void Function(String title, int colorIndex) onDownload;

  const WatchScreen({super.key, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series & Movies')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Text('Series',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          _WatchCarousel(
            titles: watchTitles.where((item) => item.series).toList(),
            onDownload: onDownload,
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Text('Movies',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          _WatchCarousel(
            titles: watchTitles.where((item) => !item.series).toList(),
            onDownload: onDownload,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WatchCarousel extends StatelessWidget {
  final List<WatchTitle> titles;
  final void Function(String title, int colorIndex) onDownload;

  const _WatchCarousel({required this.titles, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final title = titles[index];
          return SizedBox(
            width: 156,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WatchDetailScreen(
                    title: title,
                    onDownload: onDownload,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _Artwork(
                              index: title.colorIndex,
                              child: const Icon(Icons.local_movies_outlined,
                                  size: 52, color: Colors.white60)),
                          Positioned(
                            left: 8,
                            bottom: 8,
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 15, color: Color(0xFFFACC15)),
                                const SizedBox(width: 3),
                                Text(title.rating,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(title.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(title.series ? 'Series' : 'Movie',
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WatchDetailScreen extends StatelessWidget {
  final WatchTitle title;
  final void Function(String title, int colorIndex) onDownload;

  const WatchDetailScreen({
    super.key,
    required this.title,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = title.series
        ? ['A new beginning', 'The first clue', 'Crossroads', 'Coming home']
        : ['Play movie'];
    return Scaffold(
      appBar: AppBar(title: Text(title.title)),
      body: ListView(
        children: [
          SizedBox(
            height: 240,
            child: _Artwork(
              index: title.colorIndex,
              child: const Icon(Icons.play_circle_outline,
                  size: 86, color: Colors.white70),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(title.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                ),
                const Icon(Icons.star, color: Color(0xFFFACC15), size: 18),
                Text(' ${title.rating}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title.description,
                style: const TextStyle(color: Colors.white70, height: 1.4)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
            child: Text(title.series ? 'Episodes' : 'Movie',
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          for (var i = 0; i < episodes.length; i++)
            ListTile(
              leading: Container(
                width: 54,
                height: 44,
                decoration: BoxDecoration(
                  color: greenAccent.withOpacity(.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.play_arrow, color: greenAccent),
              ),
              title: Text(title.series
                  ? 'Episode ${i + 1}: ${episodes[i]}'
                  : episodes[i]),
              subtitle:
                  Text(title.series ? '${24 + i * 3} min' : '1 hr 48 min'),
              trailing: IconButton(
                tooltip: 'Download',
                onPressed: () => onDownload(
                  title.series
                      ? '${title.title} • Episode ${i + 1}'
                      : title.title,
                  title.colorIndex,
                ),
                icon: const Icon(Icons.download_outlined),
              ),
              onTap: () => _showMessage(context, 'Playing ${episodes[i]}'),
            ),
        ],
      ),
    );
  }
}

class ReelsScreen extends StatefulWidget {
  final void Function(String title, int colorIndex) onDownload;

  const ReelsScreen({super.key, required this.onDownload});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final Set<int> _liked = {};
  final reels = const [
    ('Golden hour in town', 'Amina', 0),
    ('A quick recipe from home', 'Wanjiku', 2),
    ('The road to the coast', 'Malik', 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              _Artwork(
                index: reel.$3,
                child: Icon(Icons.play_circle_outline,
                    size: 94, color: Colors.white.withOpacity(.55)),
              ),
              const Positioned(
                top: 48,
                left: 16,
                child: Text('Reels',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              Positioned(
                left: 16,
                right: 88,
                bottom: 34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${reel.$2}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 6),
                    Text(reel.$1),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.music_note, size: 15),
                        SizedBox(width: 3),
                        Text('Original audio', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                bottom: 34,
                child: Column(
                  children: [
                    _ReelAction(
                      icon: _liked.contains(index)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      label: _liked.contains(index) ? '1.2k+' : '1.2k',
                      color: _liked.contains(index)
                          ? Colors.pinkAccent
                          : Colors.white,
                      onTap: () => setState(() {
                        if (!_liked.add(index)) _liked.remove(index);
                      }),
                    ),
                    _ReelAction(
                      icon: Icons.mode_comment_outlined,
                      label: '86',
                      onTap: () =>
                          _showMessage(context, 'Reel comments opened.'),
                    ),
                    _ReelAction(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () => _showMessage(context, 'Reel link copied.'),
                    ),
                    _ReelAction(
                      icon: Icons.download_outlined,
                      label: 'Save',
                      onTap: () => widget.onDownload(reel.$1, reel.$3),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReelAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final int index;
  final Widget child;

  const _Artwork({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    const palettes = [
      [Color(0xFF115E59), Color(0xFF164E63)],
      [Color(0xFF312E81), Color(0xFF581C87)],
      [Color(0xFF7C2D12), Color(0xFF713F12)],
      [Color(0xFF0F766E), Color(0xFF365314)],
      [Color(0xFF9D174D), Color(0xFF7C2D12)],
      [Color(0xFF1E3A8A), Color(0xFF155E75)],
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palettes[index % palettes.length],
        ),
      ),
      child: Center(child: child),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Create a post',
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(
                hintText: 'What is happening in your world?'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                _showMessage(context, 'Photo picker is ready to connect.'),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Add a photo or video'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final localContext = context;
              if (_controller.text.trim().isEmpty) {
                if (!localContext.mounted) return;
                _showMessage(localContext, 'Write something before posting.');
                return;
              }
              final text = _controller.text.trim();
              final prefs = await SharedPreferences.getInstance();
              final previous = prefs.getStringList('my_posts') ?? const [];
              final posts = [...previous, text];
              await prefs.setStringList('my_posts', posts);
              if (!localContext.mounted) return;
              _showMessage(localContext, 'Your post was shared.');
              _controller.clear();
            },
            child: const Text('Share post'),
          ),
        ],
      ),
    );
  }
}

class RealChatScreen extends StatefulWidget {
  const RealChatScreen({super.key});

  @override
  State<RealChatScreen> createState() => _RealChatScreenState();
}

class _RealChatScreenState extends State<RealChatScreen> {
  final chats = [
    {'name': 'Anon_2314', 'last': 'Sawa nitakutumia', 'time': '2m'},
    {'name': 'Anon_8872', 'last': 'Uko wapi?', 'time': '1h'},
    {'name': 'Mama Mboga', 'last': 'Thanks!', 'time': '3h'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('RealChat',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(chat['name']![0])),
                  title: Text(chat['name']!),
                  subtitle: Text(chat['last']!),
                  trailing: Text(chat['time']!),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatDetail(name: chat['name']!)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDetail extends StatefulWidget {
  final String name;

  const ChatDetail({super.key, required this.name});

  @override
  State<ChatDetail> createState() => _ChatDetailState();
}

class _ChatDetailState extends State<ChatDetail> {
  final List<Map<String, Object>> _messages = [
    {'text': 'Hey', 'mine': false},
    {'text': 'Hi there', 'mine': true},
  ];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('chat_${widget.name}') ?? const [];
    if (raw.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _messages.clear();
      for (final item in raw) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        _messages.add({
          'text': decoded['text'] as String,
          'mine': decoded['mine'] as bool,
        });
      }
    });
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _messages.map((message) => jsonEncode(message)).toList();
    await prefs.setStringList('chat_${widget.name}', payload);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final mine = message['mine']! as bool;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mine ? greenAccent : cardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text']! as String,
                      style:
                          TextStyle(color: mine ? Colors.black : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;
                    setState(() => _messages.add({'text': text, 'mine': true}));
                    await _saveMessages();
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 1240.50;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _balance = prefs.getDouble('wallet_balance') ?? 1240.50;
    });
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', _balance);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Wallet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [greenAccent, Color(0xFF22C55E)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'KSh ${_balance.toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Recent activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const ListTile(
                leading: Icon(Icons.arrow_downward, color: greenAccent),
                title: Text('Creator reward'),
                subtitle: Text('Today'),
                trailing: Text('+ KSh 250')),
            const ListTile(
                leading: Icon(Icons.arrow_upward, color: Colors.orangeAccent),
                title: Text('Coffee House'),
                subtitle: Text('Yesterday'),
                trailing: Text('- KSh 180')),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      setState(() => _balance += 100);
                      await _saveBalance();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add funds'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showMessage(context, 'Withdraw request started.'),
                    icon: const Icon(Icons.north_east),
                    label: const Text('Withdraw'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final String username;
  final int avatarIndex;
  final List<DownloadItem> downloads;
  final void Function(int id) onDeleteDownload;
  final void Function(String title, int colorIndex) onDownload;
  final VoidCallback onSettings;
  final VoidCallback onAdmin;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.avatarIndex,
    required this.downloads,
    required this.onDeleteDownload,
    required this.onDownload,
    required this.onSettings,
    required this.onAdmin,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _anonymous = true;
  bool _creator = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _anonymous ? 'Anon_8421' : '@${widget.username}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Settings',
                onPressed: widget.onSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          Center(
            child: Column(
              children: [
                ProfileAvatar(index: widget.avatarIndex, radius: 44),
                const SizedBox(height: 8),
                Text(widget.username,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const Text('Hey there! I am using WhatsApp.',
                    style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ProfileStat(value: '24', label: 'Posts'),
              _ProfileStat(value: '1.8k', label: 'Followers'),
              _ProfileStat(value: '312', label: 'Following'),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Anonymous Mode'),
            subtitle: const Text('Hide your public profile details'),
            value: _anonymous,
            onChanged: (value) => setState(() => _anonymous = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Creator Mode'),
            subtitle: const Text('Show creator tools and insights'),
            value: _creator,
            onChanged: (value) => setState(() => _creator = value),
          ),
          if (_creator)
            const Card(
              child: ListTile(
                leading: Icon(Icons.insights, color: greenAccent),
                title: Text('Creator insights'),
                subtitle: Text('Your posts reached 3,420 people this month.'),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: Colors.redAccent),
            title: const Text('Moderation Panel'),
            subtitle: const Text('Review community reports'),
            onTap: widget.onAdmin,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('My Posts',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.image_outlined, color: greenAccent),
              title: Text('A day in my neighborhood'),
              subtitle: Text('12 likes • Yesterday'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 6),
          _ProfileNavigationTile(
            icon: Icons.download_outlined,
            title: 'Downloads',
            trailing: Text('${widget.downloads.length}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DownloadsScreen(
                  downloads: widget.downloads,
                  onDelete: widget.onDeleteDownload,
                ),
              ),
            ),
          ),
          _ProfileNavigationTile(
            icon: Icons.bookmark_outline,
            title: 'My Watchlist',
            trailing: const Text('3 saved'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WatchlistScreen(onDownload: widget.onDownload),
              ),
            ),
          ),
          _ProfileNavigationTile(
            icon: Icons.workspace_premium_outlined,
            title: 'Subscriptions',
            trailing: const Text('Manage'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}

class _ProfileNavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  const _ProfileNavigationTile({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: greenAccent),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          trailing,
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right)
        ],
      ),
      onTap: onTap,
    );
  }
}

class DownloadsScreen extends StatelessWidget {
  final List<DownloadItem> downloads;
  final void Function(int id) onDelete;

  const DownloadsScreen({
    super.key,
    required this.downloads,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: downloads.isEmpty
          ? const Center(
              child: Text('Your downloaded videos will appear here.'))
          : ListView.builder(
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];
                final downloading = item.progress < 1;
                return ListTile(
                  leading: SizedBox(
                    width: 58,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _Artwork(
                          index: item.colorIndex,
                          child: const Icon(Icons.play_arrow)),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: downloading
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Downloading...'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: item.progress,
                              color: greenAccent,
                              backgroundColor: Colors.white12,
                            ),
                          ],
                        )
                      : Text(item.size),
                  trailing: IconButton(
                    tooltip: 'Delete download',
                    onPressed: () => onDelete(item.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  isThreeLine: downloading,
                );
              },
            ),
    );
  }
}

class WatchlistScreen extends StatelessWidget {
  final void Function(String title, int colorIndex) onDownload;

  const WatchlistScreen({super.key, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    final titles = watchTitles.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('My Watchlist')),
      body: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final title = titles[index];
          return ListTile(
            leading: SizedBox(
              width: 58,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _Artwork(
                    index: title.colorIndex,
                    child: const Icon(Icons.movie_outlined)),
              ),
            ),
            title: Text(title.title),
            subtitle: Text(
                '★ ${title.rating} • ${title.series ? 'Series' : 'Movie'}'),
            trailing: IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => onDownload(title.title, title.colorIndex),
            ),
          );
        },
      ),
    );
  }
}

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _autoRenew = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.movie_outlined)),
            title: Text('RealWorld Plus'),
            subtitle: Text('Your plan • Renews monthly'),
            trailing: Icon(Icons.check_circle, color: greenAccent),
          ),
          ListTile(
            title: const Text('Manage subscription'),
            subtitle: const Text('Pause or update your plan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                _showMessage(context, 'Subscription management opened.'),
          ),
          SwitchListTile(
            value: _autoRenew,
            onChanged: (value) => setState(() => _autoRenew = value),
            title: const Text('Auto-renew'),
          ),
        ],
      ),
    );
  }
}

const Map<String, List<String>> _settingsOptions = {
  'Subscriptions': ['Renew my subscription', 'New episode alerts'],
  'Linked devices': [
    'Notify me about new devices',
    'Require confirmation to link'
  ],
  'Account': ['Two-step verification', 'Security notifications'],
  'Privacy': ['Read receipts', 'Online status', 'Profile photo visibility'],
  'Lists': ['Show favorites first', 'Notify when lists change'],
  'Chats': ['Save chat history', 'Media auto-download', 'Chat notifications'],
  'Appearance': ['Dark theme', 'Reduce motion', 'High contrast'],
  'Broadcasts': ['Allow broadcast replies', 'Notify for new broadcasts'],
  'Notifications': ['Message notifications', 'Sound', 'Vibration'],
  'Storage and data': [
    'Use less mobile data',
    'Auto-download on Wi-Fi',
    'Show storage alerts'
  ],
  'Parental controls': [
    'Content restrictions',
    'Screen-time reminders',
    'Require PIN for purchases'
  ],
  'Accessibility': ['Larger text', 'Screen reader labels', 'Reduce animations'],
  'App language': ['Use device language', 'Translate post captions'],
  'Help and feedback': ['Product tips', 'Send diagnostic reports'],
  'Invite a friend': ['Allow contact matching', 'Notify me when friends join'],
  'App updates': ['Automatic updates', 'Notify about new versions'],
  'Accounts Centre': [
    'Connected experiences',
    'Cross-posting',
    'Account notifications'
  ],
};

class SettingsScreen extends StatelessWidget {
  final String username;
  final int avatarIndex;
  final Future<void> Function() onLogout;

  const SettingsScreen({
    super.key,
    required this.username,
    required this.avatarIndex,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    const settings = [
      ('Subscriptions', Icons.workspace_premium_outlined),
      ('Linked devices', Icons.devices_outlined),
      ('Account', Icons.key_outlined),
      ('Privacy', Icons.lock_outline),
      ('Lists', Icons.list_alt),
      ('Chats', Icons.chat_outlined),
      ('Appearance', Icons.palette_outlined),
      ('Broadcasts', Icons.campaign_outlined),
      ('Notifications', Icons.notifications_outlined),
      ('Storage and data', Icons.storage_outlined),
      ('Parental controls', Icons.family_restroom_outlined),
      ('Accessibility', Icons.accessibility_new),
      ('App language', Icons.language),
      ('Help and feedback', Icons.help_outline),
      ('Invite a friend', Icons.person_add_alt),
      ('App updates', Icons.system_update_outlined),
      ('Accounts Centre', Icons.account_circle_outlined),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: ProfileAvatar(index: avatarIndex, radius: 30),
            title: Text(username,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Hey there! I am using WhatsApp.'),
            trailing: const Icon(Icons.qr_code_2, color: greenAccent),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsCategoryPage(
                  title: 'Profile',
                  options: [
                    'Show profile to everyone',
                    'Allow profile discovery'
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          for (final entry in settings)
            ListTile(
              leading: Icon(entry.$2, color: Colors.white70),
              title: Text(entry.$1),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () {
                if (entry.$1 == 'Subscriptions') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionsScreen()));
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsCategoryPage(
                        title: entry.$1,
                        options: _settingsOptions[entry.$1] ??
                            const ['Enable notifications', 'Allow suggestions'],
                      ),
                    ),
                  );
                }
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Log out',
                style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text(
                      'You can sign back in with your phone number.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Log out')),
                  ],
                ),
              );
              if (shouldLogout == true) await onLogout();
            },
          ),
        ],
      ),
    );
  }
}

class SettingsCategoryPage extends StatefulWidget {
  final String title;
  final List<String> options;

  const SettingsCategoryPage({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  State<SettingsCategoryPage> createState() => _SettingsCategoryPageState();
}

class _SettingsCategoryPageState extends State<SettingsCategoryPage> {
  late List<bool> _values;

  @override
  void initState() {
    super.initState();
    _values = List<bool>.generate(widget.options.length, (index) => index == 0);
    _loadValues();
  }

  Future<void> _loadValues() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _values = List<bool>.generate(
        widget.options.length,
        (index) => prefs.getBool(_preferenceKey(index)) ?? index == 0,
      );
    });
  }

  String _preferenceKey(int index) => 'setting_${widget.title}_$index';

  Future<void> _updateValue(int index, bool value) async {
    setState(() => _values[index] = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_preferenceKey(index), value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: [
          for (var index = 0; index < widget.options.length; index++)
            SwitchListTile(
              title: Text(widget.options[index]),
              subtitle: Text(
                  'Manage ${widget.options[index].toLowerCase()} for ${widget.title.toLowerCase()}.'),
              value: _values[index],
              onChanged: (value) => _updateValue(index, value),
            ),
          if (widget.title == 'Help and feedback')
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Send feedback'),
              onTap: () => _showMessage(
                  context, 'Thanks — your feedback form is ready.'),
            ),
          if (widget.title == 'App language')
            ListTile(
              title: const Text('Preferred language'),
              subtitle: const Text('English'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showMessage(context, 'English is selected.'),
            ),
        ],
      ),
    );
  }
}

class ModerationPanel extends StatelessWidget {
  const ModerationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Community reports',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          ),
          for (final report in [
            'Spam post • Anon_1102',
            'Unsafe location • Anon_3981',
            'Harassment • Anon_0432'
          ])
            ListTile(
              leading:
                  const Icon(Icons.flag_outlined, color: Colors.orangeAccent),
              title: Text(report),
              subtitle: const Text('Reported recently'),
              trailing: PopupMenuButton<String>(
                onSelected: (action) =>
                    _showMessage(context, 'Report $action.'),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'reviewed', child: Text('Mark reviewed')),
                  PopupMenuItem(
                      value: 'removed', child: Text('Remove content')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
}
