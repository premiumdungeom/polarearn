import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    final id = _identifierCtrl.text.trim();
    final pw = _passwordCtrl.text;
    if (id.isEmpty || pw.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final result = await ApiService.login(id, pw);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ──────────────────────────────
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  children: [
                    const Icon(Icons.bolt, color: AppTheme.green, size: 70),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'POLAR',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1a3d1a),
                              letterSpacing: 2,
                            ),
                          ),
                          TextSpan(
                            text: '\nEARN',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.green,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'EARN SMART. EARN DAILY.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textGray,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome Back!',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                      'Login to your PolarEarn account and continue earning.',
                      style:
                          TextStyle(fontSize: 13, color: AppTheme.textGray),
                    ),
                    const SizedBox(height: 24),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.redLight,
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                            left: BorderSide(color: AppTheme.red, width: 3),
                          ),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.red, fontSize: 13)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email / Username
                    _label('Email or Username'),
                    _inputField(
                      controller: _identifierCtrl,
                      hint: 'Enter email or username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _label('Password'),
                    _inputField(
                      controller: _passwordCtrl,
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      obscure: _obscure,
                      suffix: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textGray,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Login',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textGray)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/register'),
                          child: const Text('Create Account',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.green)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Footer ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppTheme.greenDark,
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 36),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Secure • Trusted • Reliable',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        Text('Your security is our priority',
                            style: TextStyle(
                                color: Color(0xFFa5d6a7), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) =>
      Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(icon, color: AppTheme.green, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                      color: AppTheme.textLight, fontSize: 13),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            if (suffix != null) suffix,
          ],
        ),
      );

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
