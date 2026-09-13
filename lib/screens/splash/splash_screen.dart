import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/screens/auth/login_screen.dart';
import 'package:kisanbazaar/screens/buyer/buyer_dashboard.dart';
import 'package:kisanbazaar/screens/seller/seller_dashboard.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _checkUserStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkUserStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      User? user = FirebaseAuth.instance.currentUser;

      // Logic fix: Ensure user is signed in AND has verified their email.
      if (user == null || !user.emailVerified) {
        _navigateToScreen(const LoginScreen());
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (!mounted) return;

      if (!userDoc.exists) {
        _navigateToScreen(const LoginScreen());
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String role = (userData['role'] ?? '').toString().trim().toLowerCase();

      if (role == 'buyer') {
        _navigateToScreen(const BuyerDashboard());
      } else if (role == 'seller') {
        _navigateToScreen(const SellerDashboard());
      } else {
        _navigateToScreen(const LoginScreen());
      }
    } catch (e) {
      debugPrint('Error in _checkUserStatus: $e');
      if (mounted) _navigateToScreen(const LoginScreen());
    }
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "KisanBazaar",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fresh From Farmers 🌾",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
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
