import 'package:flutter/material.dart';

void main() {
  runApp(const CyberVaultApp());
}

class CyberVaultApp extends StatelessWidget {
  const CyberVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CyberVault',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505), // Pitch OLED Black
        primaryColor: Colors.greenAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF111111),
        ),
      ),
      home: const VaultHomeScreen(),
    );
  }
}

class VaultHomeStateItem {
  final String title;
  final String subtitle;
  final String date;

  VaultHomeStateItem({required this.title, required this.subtitle, required this.date});
}

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({Key? key}) : super(key: key);

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  // Sample secret notes/items in the vault
  final List<VaultHomeStateItem> _vaultItems = [
    VaultHomeStateItem(title: 'Root Passwords', subtitle: 'Encrypted AES-256', date: '07 Oct 2026'),
    VaultHomeStateItem(title: 'Telegram API Hash', subtitle: 'Hidden token config', date: '05 Oct 2026'),
    VaultHomeStateItem(title: 'Server SSH Keys', subtitle: 'Private key backup', date: '01 Oct 2026'),
  ];

  void _addNewNote() {
    // Quick dialog to add a mock secret note
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController contentController = TextEditingController();

        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.greenAccent, width: 1),
          ),
          title: const Text(
            'NEW ENCRYPTED ENTRY',
            style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'monospace'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Title / Tag',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Secret Data',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _vaultItems.insert(
                      0,
                      VaultHomeStateItem(
                        title: titleController.text,
                        subtitle: contentController.text.isEmpty ? 'Encrypted data' : contentController.text,
                        date: 'Just now',
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('LOCK IN VAULT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '// C Y B E R _ V A U L T',
          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.greenAccent.withOpacity(0.3), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status bar banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, color: Colors.greenAccent),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'STATUS: SECURE // LOCAL ENCRYPTION ACTIVE',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'STORED SECRETS',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _vaultItems.length,
                itemBuilder: (context, index) {
                  final item = _vaultItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const Icon(Icons.lock_outline, color: Colors.greenAccent),
                      title: Text(
                        item.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.subtitle,
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                      trailing: Text(
                        item.date,
                        style: const TextStyle(color: Colors.white30, fontSize: 11),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        onPressed: _addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
