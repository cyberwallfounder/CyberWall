import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

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
      home: const AppLockScreen(), // Pehle Lock Screen aayegi
    );
  }
}

class VaultItem {
  final String title;
  final String secretData;
  final String date;

  VaultItem({required this.title, required this.secretData, required this.date});

  Map<String, dynamic> toJson() => {
        'title': title,
        'secretData': secretData,
        'date': date,
      };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
        title: json['title'],
        secretData: json['secretData'],
        date: json['date'],
      );
}

// ==================== 1. APP LOCK SCREEN ====================
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLocked = true;

  void _verifyPin() {
    // Default Vault Passcode is set to 1234 (User can change or we can keep it secure)
    if (_pinController.text == '1234') {
      setState(() {
        _isLocked = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VaultHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ACCESS DENIED: Invalid Passcode! (Try 1234)'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 80, color: Colors.greenAccent),
              const SizedBox(height: 20),
              const Text(
                '// SECURE_VAULT_LOCK',
                style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter passcode to decrypt workspace',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 24, letterSpacing: 8, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    counterText: '',
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: _verifyPin,
                child: const Text('UNLOCK VAULT', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 2. VAULT HOME SCREEN ====================
class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({Key? key}) : super(key: key);

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  // Default items removed completely! Clean slate for user.
  final List<VaultItem> _vaultItems = [];

  Timer? _holdTimer;
  double _holdProgress = 0.0;

  // 10-Second Long Press Detect Start for Admin Panel
  void _startAdminHold(LongPressStartDetails details) {
    _holdProgress = 0.0;
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _holdProgress += 0.01; // 10 seconds total (100 * 100ms)
        if (_holdProgress >= 1.0) {
          timer.cancel();
          _holdProgress = 0.0;
          _openAdminLogin();
        }
      });
    });
  }

  void _cancelAdminHold(LongPressEndDetails details) {
    _holdTimer?.cancel();
    setState(() {
      _holdProgress = 0.0;
    });
  }

  void _openAdminLogin() {
    final TextEditingController userController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        title: const Text(
          'ADMIN OVERRIDE PORTAL',
          style: TextStyle(color: Colors.redAccent, fontSize: 16, fontFamily: 'monospace', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Admin Username',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Admin Password',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              if (userController.text == 'aanu' && passController.text == 'aanuhavker') {
                Navigator.pop(context);
                _navigateToAdminPanel();
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ACCESS REJECTED: Invalid Admin Credentials!'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('LOGIN ADMIN', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminPanelScreen(vaultItems: _vaultItems)),
    );
  }

  String _encryptData(String plainText) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(plainText);
    return "CYBER_SECURE_$encoded";
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
              'Copy this encrypted backup string. Safe to store anywhere:',
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
              'Paste your encrypted backup code below:',
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
    return GestureDetector(
      onLongPressStart: _startAdminHold,
      onLongPressEnd: _cancelAdminHold,
      child: Scaffold(
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
            preferredSize: const Size.fromHeight(2),
            child: Column(
              children: [
                if (_holdProgress > 0)
                  LinearProgressIndicator(
                    value: _holdProgress,
                    backgroundColor: Colors.black,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                  ),
                Container(color: Colors.greenAccent.withOpacity(0.3), height: 1),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background Watermark Logo for New Users
            Center(
              child: Opacity(
                opacity: 0.05,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.fingerprint, size: 120, color: Colors.greenAccent),
                    SizedBox(height: 10),
                    Text(
                      'SECRETVAULTX',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Main Content Area
            Padding(
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
                            'STATUS: SECURE // ZERO DEFAULT RECORDS',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'STORED RECORDS',
                    style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _vaultItems.isEmpty
                        ? Center(
                            child: Text(
                              'VAULT EMPTY\nTap + to store secure credentials',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white24, fontFamily: 'monospace', height: 1.5),
                            ),
                          )
                        : ListView.builder(
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
          onPressed: _addNewNote,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// ==================== 3. ADMIN PANEL SCREEN ====================
class AdminPanelScreen extends StatelessWidget {
  final List<VaultItem> vaultItems;

  const AdminPanelScreen({Key? key, required this.vaultItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '// ADMIN MASTER OVERVIEW',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.redAccent),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.redAccent.withOpacity(0.5), height: 1),
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
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'LOGGED IN AS: aanu // TOTAL RECORDS: ${vaultItems.length}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ALL USER STORED VAULT DATABASE',
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: vaultItems.isEmpty
                  ? const Center(
                      child: Text(
                        'NO RECORDS FOUND IN MASTER DB',
                        style: TextStyle(color: Colors.white24, fontFamily: 'monospace'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: vaultItems.length,
                      itemBuilder: (context, index) {
                        final item = vaultItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D0D0D),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.storage, color: Colors.redAccent),
                            title: Text(
                              item.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                            subtitle: Text(
                              'Data: ${item.secretData}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
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
    );
  }
}
