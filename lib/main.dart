import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? savedPin = prefs.getString('user_vault_pin');

  runApp(VaultXApp(isFirstTime: savedPin == null));
}

class VaultXApp extends StatelessWidget {
  final bool isFirstTime;
  const VaultXApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VAULTX',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF010402),
        primaryColor: Colors.greenAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF0A0F0D),
        ),
      ),
      home: isFirstTime ? const SetupPinScreen() : const AppLockScreen(),
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
        title: json['title'] ?? 'Untitled',
        secretData: json['secretData'] ?? '',
        date: json['date'] ?? 'Unknown',
      );
}

// ==================== CUSTOM VAULTX LOGO WIDGET ====================
class VaultLogo extends StatelessWidget {
  final double size;
  const VaultLogo({Key? key, this.size = 80}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A140E),
        border: Border.all(color: Colors.greenAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.35),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Icon(
            Icons.shield_outlined,
            size: 45,
            color: Colors.greenAccent,
          ),
          Icon(
            Icons.lock_rounded,
            size: 20,
            color: Colors.cyanAccent,
          ),
        ],
      ),
    );
  }
}

// Reusable Cyber Background Decorator Widget
class CyberBackground extends StatelessWidget {
  final Widget child;
  const CyberBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020904),
            Color(0xFF010402),
            Color(0xFF02060A),
          ],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

// ==================== 1. FIRST TIME SETUP PIN SCREEN ====================
class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({Key? key}) : super(key: key);

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _errorMessage = '';

  void _savePin() async {
    String pin = _pinController.text.trim();
    String confirmPin = _confirmPinController.text.trim();

    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() {
        _errorMessage = 'ERROR: Please enter a valid 4-digit numeric PIN!';
      });
      return;
    }

    if (pin != confirmPin) {
      setState(() {
        _errorMessage = 'ERROR: PIN mismatch! Verify digits.';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_vault_pin', pin);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VaultHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VaultLogo(size: 95),
                  const SizedBox(height: 24),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '// INITIALIZE VAULTX_PIN',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Set your master security sequence to encrypt local workspace storage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _pinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: '4-Digit PIN',
                        labelStyle: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontSize: 12),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _confirmPinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        labelText: 'Confirm PIN',
                        labelStyle: TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontSize: 12),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                  const SizedBox(height: 35),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _savePin,
                    child: const Text(
                      'ESTABLISH VAULT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 15, letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 2. APP LOCK SCREEN ====================
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({Key? key}) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';

  void _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    String? correctPin = prefs.getString('user_vault_pin');

    if (_pinController.text.trim() == correctPin) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VaultHomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'ACCESS DENIED: Invalid Passcode Signature!';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VaultLogo(size: 95),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '// V A U L T X _ L O C K E D',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Provide master authorization sequence to decrypt storage container.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _pinController,
                      obscureText: true,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
                      ),
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _verifyPin,
                    child: const Text(
                      'DECRYPT VAULT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== 3. VAULT HOME SCREEN ====================
class VaultHomeScreen extends StatefulWidget {
  const VaultHomeScreen({Key? key}) : super(key: key);

  @override
  State<VaultHomeScreen> createState() => _VaultHomeScreenState();
}

class _VaultHomeScreenState extends State<VaultHomeScreen> {
  final List<VaultItem> _vaultItems = [];
  bool _isLoading = true;

  Timer? _holdTimer;
  double _holdProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStoredVaultItems();
  }

  void _loadStoredVaultItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('saved_vault_records');
    if (storedData != null) {
      try {
        List decodedList = jsonDecode(storedData);
        setState(() {
          _vaultItems.clear();
          for (var item in decodedList) {
            _vaultItems.add(VaultItem.fromJson(item));
          }
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveVaultItemsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = _vaultItems.map((item) => item.toJson()).toList();
    await prefs.setString('saved_vault_records', jsonEncode(jsonList));
  }

  void _startAdminHold(LongPressStartDetails details) {
    _holdProgress = 0.0;
    _holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _holdProgress += 0.01;
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
        backgroundColor: const Color(0xFF0D1410),
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
              if (userController.text.trim() == 'aanu' && passController.text.trim() == 'aanuhavker') {
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
    return "VAULTX_SECURE_$encoded";
  }

  String _decryptData(String encryptedText) {
    try {
      if (!encryptedText.startsWith("VAULTX_SECURE_")) return encryptedText;
      String rawBase64 = encryptedText.replaceFirst("VAULTX_SECURE_", "");
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
        backgroundColor: const Color(0xFF0D1410),
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
              'Copy this encrypted backup string. Completely safe to store anywhere:',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              height: 130,
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
        backgroundColor: const Color(0xFF0D1410),
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
              'Paste your encrypted backup code below to restore local records:',
              style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
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
                _saveVaultItemsToStorage();
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
          backgroundColor: const Color(0xFF0D1410),
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
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Secret Data / Credential',
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
                if (titleController.text.trim().isNotEmpty) {
                  setState(() {
                    _vaultItems.insert(
                      0,
                      VaultItem(
                        title: titleController.text.trim(),
                        secretData: contentController.text.trim().isEmpty ? 'Hidden Payload' : contentController.text.trim(),
                        date: 'Just now',
                      ),
                    );
                  });
                  _saveVaultItemsToStorage();
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
        body: CyberBackground(
          child: Column(
            children: [
              AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    VaultLogo(size: 28),
                    SizedBox(width: 10),
                    Text(
                      '// V A U L T X',
                      style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16),
                    ),
                  ],
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.shield_outlined, color: Colors.greenAccent),
                    color: const Color(0xFF0D1410),
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
              ),
              PreferredSize(
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
                    : Stack(
                        children: [
                          const Center(
                            child: Opacity(
                              opacity: 0.05,
                              child: VaultLogo(size: 220),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A140E),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.lock_clock, color: Colors.greenAccent, size: 20),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'STATUS: SECURE // PERSISTENT STORAGE ACTIVE',
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
                                                color: const Color(0xFF070C09),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.greenAccent.withOpacity(0.15)),
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
      ),
    );
  }
}

// ==================== 4. ADMIN PANEL SCREEN ====================
class AdminPanelScreen extends StatelessWidget {
  final List<VaultItem> vaultItems;

  const AdminPanelScreen({Key? key, required this.vaultItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberBackground(
        child: Column(
          children: [
            AppBar(
              title: const Text(
                '// ADMIN MASTER OVERVIEW',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 16),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.redAccent),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: Colors.redAccent.withOpacity(0.5), height: 1),
              ),
            ),
            Expanded(
              child: Padding(
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
                              itemBuilder: (index) {
                                final item = vaultItems[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF140808),
                                            borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(Icons.storage, color: Colors.redAccent),
                                    title: Text(
                                      item.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Data: ${item.secretData}',
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
            ),
          ],
        ),
      ),
    );
  }
}
