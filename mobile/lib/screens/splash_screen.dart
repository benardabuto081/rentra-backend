import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';
import 'main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await AuthService.loadSession();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (AuthService.token != null && AuthService.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'R',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Rentra',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your rental identity, organized.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 56),
            const CircularProgressIndicator(
              color: Colors.white38,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}