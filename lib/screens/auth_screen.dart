import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

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
      backgroundColor: Colors.black, // Solid black background for terminal look
      body: Stack(
        children: [
          // Cyberpunk Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: GridBackgroundPainter(),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: _hasMasterPassword ? _buildUnlockForm() : _buildSetupForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalHeader(BuildContext context, {required String statusText}) {
    final textStyle = GoogleFonts.jetBrainsMono(
      fontSize: context.sp(9),
      color: const Color(0xFF6B6B6B),
      fontWeight: FontWeight.bold,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('[ STATUS:', style: textStyle),
            Text('$statusText ]', style: textStyle.copyWith(color: kColorPrimary)),
          ],
        ),
        // Center Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('[', style: textStyle),
            Text('NODE_01_OS_BOOTED', style: textStyle),
            Text(']', style: textStyle),
          ],
        ),
        // Right Column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('[ ENCRYPTION:', style: textStyle),
            Text('AES_256 ]', style: textStyle),
          ],
        ),
      ],
    );
  }

  Widget _buildScanningReticle(BuildContext context, {required IconData icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Top-left red corner bracket
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.red, width: 3),
                    left: BorderSide(color: Colors.red, width: 3),
                  ),
                ),
              ),
            ),
            // Circular container with lock icon
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.withAlpha(51), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.red,
                  shadows: [
                    Shadow(
                      color: Colors.red.withAlpha(204),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.hp(1.5)),
        // Red horizontal accent line below the reticle
        Container(
          width: 32,
          height: 3,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B0000), // Crimson
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF8B0000).withAlpha(102),
          disabledForegroundColor: Colors.white.withAlpha(102),
          shadowColor: Colors.red.withAlpha(128),
          elevation: 5,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Sharp sci-fi corners
            side: BorderSide(color: Colors.redAccent, width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: _isAuthenticating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                text,
                style: GoogleFonts.anton(
                  fontSize: context.sp(18),
                  letterSpacing: 2,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorPanel(BuildContext context) {
    if (_error == null) return const SizedBox.shrink();

    final errorTag = _error!.toUpperCase().replaceAll(' ', '_');

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: context.hp(2)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x11FF0000), // Faint red warning box
        border: Border.all(color: Colors.redAccent.withAlpha(77), width: 1),
      ),
      child: Text(
        '[ ERROR: $errorTag ]',
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
          fontSize: context.sp(12),
        ),
      ),
    );
  }

  Widget _buildUnlockForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTerminalHeader(context, statusText: 'SECURE_LOCKDOWN'),
        SizedBox(height: context.hp(6)),
        _buildScanningReticle(context, icon: Icons.lock),
        SizedBox(height: context.hp(4)),
        Text(
          'UNLOCK BATLOCKER',
          style: GoogleFonts.anton(
            fontSize: context.sp(26),
            color: const Color(0xFFFFA79A), // Peach/orange-pink glow
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.red.withAlpha(204),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        SizedBox(height: context.hp(4)),
        LockerTextField(
          controller: _passwordController,
          obscureText: true,
          hintText: 'Master Password',
          onSubmitted: (_) => _checkPassword(),
        ),
        SizedBox(height: context.hp(4)),
        _buildActionButton(
          context,
          text: 'UNLOCK',
          onPressed: _isAuthenticating ? null : _checkPassword,
        ),
        _buildErrorPanel(context),
      ],
    );
  }

  Widget _buildSetupForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTerminalHeader(context, statusText: 'PENDING_INITIALIZATION'),
        SizedBox(height: context.hp(4)),
        _buildScanningReticle(context, icon: Icons.lock_open),
        SizedBox(height: context.hp(3)),
        Text(
          'CREATE PASSWORD',
          style: GoogleFonts.anton(
            fontSize: context.sp(26),
            color: const Color(0xFFFFA79A), // Peach/orange-pink glow
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.red.withAlpha(204),
                blurRadius: 12,
              ),
            ],
          ),
        ),
        SizedBox(height: context.hp(3)),
        LockerTextField(
          controller: _newPasswordController,
          obscureText: true,
          hintText: 'New Password',
        ),
        SizedBox(height: context.hp(2)),
        LockerTextField(
          controller: _confirmPasswordController,
          obscureText: true,
          hintText: 'Confirm Password',
        ),
        SizedBox(height: context.hp(4)),
        _buildActionButton(
          context,
          text: 'SET PASSWORD',
          onPressed: _isAuthenticating ? null : _setMasterPassword,
        ),
        _buildErrorPanel(context),
      ],
    );
  }
}

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0CFF0000) // Extremely faint red lines for grid effect
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 24.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 