import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;
  bool _loading = false;
  bool _agreed = true;
  String? _error;
  double _strength = 0;

  void _checkStrength(String pw) {
    double s = 0;
    if (pw.length >= 8) s += 0.2;
    if (pw.contains(RegExp(r'[A-Z]'))) s += 0.2;
    if (pw.contains(RegExp(r'[0-9]'))) s += 0.2;
    if (pw.contains(RegExp(r'[^A-Za-z0-9]'))) s += 0.2;
    if (pw.length >= 12) s += 0.2;
    setState(() => _strength = s);
  }

  Color get _strengthColor {
    if (_strength <= 0.4) return AppTheme.red;
    if (_strength <= 0.6) return Colors.orange;
    return AppTheme.green;
  }

  Future<void> _register() async {
    if (!_agreed) {
      setState(() => _error = 'You must agree to the Terms & Conditions');
      return;
    }
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty ||
        confirm.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final result = await ApiService.register(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirm,
      referredBy: _referralCtrl.text.trim(),
    );

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
              // Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                child: Column(
                  children: [
                    const Icon(Icons.bolt, color: AppTheme.green, size: 64),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(children: [
                        TextSpan(
                          text: 'POLAR',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1a3d1a),
                          ),
                        ),
                        TextSpan(
                          text: '\nEARN',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.green,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 4),
                    const Text('EARN SMART. EARN DAILY.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textGray,
                          letterSpacing: 2.5,
                        )),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Account',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text('Join PolarEarn today and start earning.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textGray)),
                    const SizedBox(height: 20),

                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.redLight,
                          borderRadius: BorderRadius.circular(10),
                          border: const Border(
                              left:
                                  BorderSide(color: AppTheme.red, width: 3)),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppTheme.red, fontSize: 13)),
                      ),
                      const SizedBox(height: 14),
                    ],

                    _label('Username'),
                    _field(_usernameCtrl, 'Choose a username',
                        Icons.person_outline),
                    const SizedBox(height: 12),

                    _label('Email Address'),
                    _field(_emailCtrl, 'Enter your email',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),

                    _label('Password'),
                    _field(_passwordCtrl, 'Create a password',
                        Icons.lock_outline,
                        obscure: _obscure1,
                        onChanged: _checkStrength,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure1
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppTheme.textGray,
                          ),
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                        )),
                    // Strength bar
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _strength,
                        backgroundColor: AppTheme.border,
                        color: _strengthColor,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _label('Confirm Password'),
                    _field(_confirmCtrl, 'Confirm your password',
                        Icons.lock_outline,
                        obscure: _obscure2,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure2
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: AppTheme.textGray,
                          ),
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                        )),
                    const SizedBox(height: 12),

                    _label('Referral Code (Optional)'),
                    _field(_referralCtrl, 'e.g. PE-XXXXXXXX',
                        Icons.card_giftcard_outlined),
                    const SizedBox(height: 16),

                    // Terms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                          activeColor: AppTheme.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(children: [
                                const TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(fontSize: 12)),
                                const TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(
                                    text: ' and ',
                                    style: TextStyle(fontSize: 12)),
                                const TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Create Account',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ',
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.textGray)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                          child: const Text('Login',
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

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
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
                controller: ctrl,
                obscureText: obscure,
                keyboardType: keyboardType,
                onChanged: onChanged,
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
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _referralCtrl.dispose();
    super.dispose();
  }
}
