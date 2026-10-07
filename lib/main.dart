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
