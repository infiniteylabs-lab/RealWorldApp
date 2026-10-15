import 'package:flutter/material.dart';
class RealWorldSettingsScreen extends StatelessWidget {
  const RealWorldSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark? const Color(0xFF0B141A) : const Color.fromARGB(255, 116, 144, 187);
    final tileColor = isDark? const Color.fromARGB(255, 20, 33, 41) : const Color.fromARGB(255, 219, 150, 150);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: tileColor,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      ),
      body: ListView(
        children: [
          ListTile(
            tileColor: tileColor,
            leading: const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30)),
            title: const Text('Anonymous User', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Your anonymous local network • Kutus'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.qr_code)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _section(tileColor, [
            _tile(context, Icons.videocam_outlined, 'Video Calling', 'Camera, mic, call alerts', const VideoCallingSettingsPage()),
            _tile(context, Icons.groups_outlined, 'Meet Points', 'Nearby spots, radius, create meetup', const MeetPointsSettingsPage()),
            _tile(context, Icons.explore_outlined, 'Discover', 'Find people near you', null),
          ]),
          _section(tileColor, [
            _tile(context, Icons.key_outlined, 'Account', 'Anonymous ID, safety number', null),
            _tile(context, Icons.lock_outline, 'Privacy', 'Blocked users, disappearing messages', null),
            _tile(context, Icons.chat_outlined, 'Chats', 'Chat history, backup', null),
          ]),
          _section(tileColor, [
            _tile(context, Icons.palette_outlined, 'Appearance', 'Chat theme, app icon, app theme', null),
            _tile(context, Icons.notifications_outlined, 'Notifications', 'Message, group & call tones', null),
            _tile(context, Icons.storage_outlined, 'Storage and data', 'Network usage, auto-download', null),
          ]),
          _section(tileColor, [
            _tile(context, Icons.help_outline, 'Help and feedback', 'Help Centre, contact us, privacy policy', null),
            _tile(context, Icons.person_add_outlined, 'Invite a friend', 'Share RealWorld KE', null),
            _tile(context, Icons.system_update_outlined, 'App updates', 'Version 1.0.0', null),
          ]),
        ],
      ),
    );
  }

  Widget _section(Color color, List<Widget> tiles) {
    return Container(color: color, margin: const EdgeInsets.only(bottom: 10), child: Column(children: tiles));
  }

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, Widget? page) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page ?? Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text('$title coming soon')))));
},

    );
  }
}

class VideoCallingSettingsPage extends StatefulWidget {
  const VideoCallingSettingsPage({super.key});
  @override
  State<VideoCallingSettingsPage> createState() => _VideoCallingSettingsPageState();
}

class _VideoCallingSettingsPageState extends State<VideoCallingSettingsPage> {
  bool hdVideo = true;
  bool noiseCancel = true;
  bool showCallAlerts = true;
  String camera = 'Front Camera';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Calling')),
      body: ListView(
        children: [
          SwitchListTile(title: const Text('Show call alerts'), value: showCallAlerts, onChanged: (v) => setState(() => showCallAlerts = v)),
          SwitchListTile(title: const Text('HD Video'), subtitle: const Text('Use high quality when on WiFi'), value: hdVideo, onChanged: (v) => setState(() => hdVideo = v)),
          SwitchListTile(title: const Text('Noise cancellation'), value: noiseCancel, onChanged: (v) => setState(() => noiseCancel = v)),
          ListTile(
            title: const Text('Default camera'),
            subtitle: Text(camera),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final sel = await showDialog<String>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('Default camera'),
                  children: ['Front Camera','Rear Camera'].map((c) => SimpleDialogOption(child: Text(c), onPressed: ()=> Navigator.pop(context, c))).toList(),
                ),
              );
              if (sel!= null) setState(() => camera = sel);
            },
          ),
        ],
      ),
    );
  }
}

class MeetPointsSettingsPage extends StatefulWidget {
  const MeetPointsSettingsPage({super.key});
  @override
  State<MeetPointsSettingsPage> createState() => _MeetPointsSettingsPageState();
}

class _MeetPointsSettingsPageState extends State<MeetPointsSettingsPage> {
  bool shareLocation = true;
  bool publicMeetups = true;
  double radius = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meet Points')),
      body: ListView(
        children: [
          SwitchListTile(title: const Text('Share my approximate location'), value: shareLocation, onChanged: (v) => setState(() => shareLocation = v)),
          ListTile(title: const Text('Discovery radius'), subtitle: Text('${radius.toStringAsFixed(0)} km around me')),
          Slider(value: radius, min: 1, max: 20, divisions: 19, label: '${radius.toStringAsFixed(0)} km', onChanged: (v) => setState(() => radius = v)),
          SwitchListTile(title: const Text('Show my public meetups'), value: publicMeetups, onChanged: (v) => setState(() => publicMeetups = v)),
          const ListTile(leading: Icon(Icons.add_location_alt_outlined), title: Text('Create new meet point'), trailing: Icon(Icons.chevron_right)),
          const ListTile(leading: Icon(Icons.history), title: Text('My meet points'), subtitle: Text('Manage saved spots'), trailing: Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}