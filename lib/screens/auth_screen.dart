import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isAuthenticating = false;
  String? _error;
  bool _hasMasterPassword = false;

  @override
  void initState() {
    super.initState();
    _checkMasterPassword();
  }

  Future<void> _checkMasterPassword() async {
    String? storedPassword = await secureStorage.read(key: 'master_password');
    setState(() {
      _hasMasterPassword = storedPassword != null;
    });
  }

  Future<void> _checkPassword() async {
    setState(() { _isAuthenticating = true; _error = null; });
    String? storedPassword = await secureStorage.read(key: 'master_password');
    if (storedPassword == _passwordController.text) {
      _onAuthenticated();
    } else {
      setState(() {
        _error = 'Incorrect password';
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _setMasterPassword() async {
    setState(() { _isAuthenticating = true; _error = null; });
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields';
        _isAuthenticating = false;
      });
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = 'Passwords do not match';
        _isAuthenticating = false;
      });
      return;
    }
    await secureStorage.write(key: 'master_password', value: _newPasswordController.text);
    setState(() {
      _hasMasterPassword = true;
      _isAuthenticating = false;
      _error = null;
    });
    _onAuthenticated();
  }

  void _onAuthenticated() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _hasMasterPassword ? _buildUnlockForm() : _buildSetupForm(),
        ),
      ),
    );
  }

  Widget _buildUnlockForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock, size: 80, color: Colors.red[400]),
        const SizedBox(height: 24),
        Text('Unlock BatLocker', style: TextStyle(fontSize: 24, color: Colors.red[200], fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Master Password',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _checkPassword(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isAuthenticating ? null : _checkPassword,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isAuthenticating ? const CircularProgressIndicator(color: Colors.white) : const Text('Unlock'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
      ],
    );
  }

  Widget _buildSetupForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 80, color: Colors.red[400]),
        const SizedBox(height: 24),
        Text('Set Master Password', style: TextStyle(fontSize: 24, color: Colors.red[200], fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isAuthenticating ? null : _setMasterPassword,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: _isAuthenticating ? const CircularProgressIndicator(color: Colors.white) : const Text('Set Password'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
      ],
    );
  }
} 