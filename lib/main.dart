import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/theme.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/withdraw_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const PolarEarnApp());
}

class PolarEarnApp extends StatelessWidget {
  const PolarEarnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolarEarn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashRouter(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/accounts': (_) => const AccountsScreen(),
        '/withdraw': (_) => const WithdrawScreen(),
      },
    );
  }
}

/// Checks if the user is already logged in and routes accordingly
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final session = await ApiService.getSession();
    if (!mounted) return;
    if (session != null) {
      // Verify session is still valid
      final result = await ApiService.getDashboard();
      if (!mounted) return;
      if (result.success) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.green,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(
              'PolarEarn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'EARN SMART. EARN DAILY.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
