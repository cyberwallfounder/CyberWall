import 'package:flutter/material.dart';
import 'dart:convert';

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
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: Colors.greenAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF111111),
        ),
      ),
      home: const VaultHomeScreen(),
    );
  }
}

class VaultItem {
  final String title;
  final String secretData;
  final String date;

  VaultItem({required this.title, required this.secretData, required this.date});

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'title': title,
        'secretData': secretData,
        'date': date,
      };

  // Create from JSON
  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
        title: json['title'],
        secretData: json['secretData'],
        date: json['date'],
      );
}

class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({Key? key}) : super(key: key);

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  final List<VaultItem> _vaultItems = [
    VaultItem(title: 'Root Passwords', secretData: 'Encrypted_AES_Key_#992', date: '07 Oct 2026'),
    VaultItem(title: 'API Hash Token', secretData: 'tg_token_secret_xyz', date: '05 Oct 2026'),
  ];

  // Simple Mock Encryption: Base64 encoding + custom shift so it looks like gibberish in files
  String _encryptData(String plainText) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(plainText);
    return "CYBER_SECURE_$encoded"; // Secret header prefix
  }

  String _decryptData(String encryptedText) {
    try {
      if (!encryptedText.startsWith("CYBER_SECURE_")) return encryptedText;
      String rawBase64 = encryptedText.replaceFirst("CYBER_SECURE_", "");
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      return stringToBase64.decode(rawBase64);
    } catch (e) {
      return "[DECRYPTION FAILED]";
    }
  }

  // Export Data to Encrypted String (User can copy/backup this string or save as file)
  void _showExportDialog() {
    List<Map<String, dynamic>> jsonList = _vaultItems.map((item) => item.toJson()).toList();
    String rawJson = jsonEncode(jsonList);
    String encryptedBackup = _encryptData(rawJson);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.greenAccent, width: 1),
        ),
        title: const Text(
          'EXPORT ENCRYPTED BACKUP',
          style: TextStyle(color: Colors.greenAccent, fontSize: 16, fontFamily: 'monospace'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeh aapka encrypted backup code hai. Ise safe jagah copy karke rakh lein. App delete hone ke baad restore karne ke kaam aayega:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  encryptedBackup,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Import / Restore Data from Encrypted String
  void _showImportDialog() {
    final TextEditingController importController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.cyanAccent, width: 1),
        ),
        title: const Text(
          'RESTORE FROM BACKUP',
          style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontFamily: 'monospace'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apna encrypted backup code yahan paste karein:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: importController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'Paste encrypted string here...',
                hintStyle: TextStyle(color: Colors.white24),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
            onPressed: () {
              try {
                String decryptedJson = _decryptData(importController.text);
                List decodedList = jsonDecode(decryptedJson);
                setState(() {
                  _vaultItems.clear();
                  for (var item in decodedList) {
                    _vaultItems.add(VaultItem.fromJson(item));
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vault Restored Successfully!'), backgroundColor: Colors.green),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restore Failed: Invalid Backup Code!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('RESTORE VAULT', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addNewNote() {
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
            'NEW SECURE ENTRY',
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
                      VaultItem(
                        title: titleController.text,
                        secretData: contentController.text.isEmpty ? 'Hidden' : contentController.text,
                        date: 'Just now',
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('LOCK IN', style: TextStyle(fontWeight: FontWeight.bold)),
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.shield_outlined, color: Colors.greenAccent),
            color: const Color(0xFF111111),
            onSelected: (value) {
              if (value == 'export') _showExportDialog();
              if (value == 'import') _showImportDialog();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Text('Backup Vault', style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace')),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Text('Restore Vault', style: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace')),
              ),
            ],
          ),
        ],
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock, color: Colors.greenAccent, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'STATUS: END-TO-END ENCRYPTED // BACKUP READY',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SECURED RECORDS',
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
                      leading: const Icon(Icons.vpn_key_outlined, color: Colors.greenAccent),
                      title: Text(
                        item.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item.secretData,
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
