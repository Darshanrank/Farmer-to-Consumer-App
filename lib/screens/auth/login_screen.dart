import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/screens/auth/signup_screen.dart';
import 'package:kisanbazaar/screens/buyer/buyer_dashboard.dart';
import 'package:kisanbazaar/screens/seller/seller_dashboard.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> login() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError("Please enter your password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          _showError("Please verify your email address");
          return;
        }

        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data() != null && mounted) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'buyer';
          _navigateToDashboard(role);
        } else {
          _showError("User record not found. Please contact support.");
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(String role) {
    if (role == "buyer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BuyerDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SellerDashboard()));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.eco_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text("Welcome to\nKisaanBazaar", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text("Empowering farmers, serving you.", style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 48),
              _buildLabel("Email Address"),
              _buildTextField(_emailController, "e.g. name@example.com", Icons.email_rounded, false),
              const SizedBox(height: 20),
              _buildLabel("Password"),
              _buildTextField(_passwordController, "Enter your password", Icons.lock_rounded, true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () {}, child: const Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13))),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : login,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  TextButton(onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                  }, child: const Text("Join Now", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: AppColors.textSecondary, size: 20), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
