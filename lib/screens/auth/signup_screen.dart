import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/screens/auth/login_screen.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedRole;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> signup() async {
    if (_emailController.text.trim().isEmpty) {
      _showError("Please enter your email");
      return;
    }
    if (_passwordController.text.length < 6) {
      _showError("Password should be at least 6 characters");
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError("Passwords do not match");
      return;
    }
    if (selectedRole == null) {
      _showError("Please select a role");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          "fullName": _fullNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": "+91 ${_phoneController.text.trim()}",
          "role": selectedRole!.toLowerCase(),
          "uid": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

        await user.sendEmailVerification();
        if (!mounted) return;

        _showSuccess("Verification email sent! Please check your inbox.");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "An error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.error));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))
        )
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create Account", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              const Text("Join our community of farmers and buyers.", style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              
              const Text("I am a...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _roleCard("Buyer", "🛍️", "I want to buy")),
                   const SizedBox(width: 16),
                   Expanded(child: _roleCard("Seller", "🚜", "I want to sell")),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildLabel("Full Name"),
              _buildTextField(_fullNameController, "e.g. John Doe", Icons.person_rounded),
              const SizedBox(height: 20),
              
              _buildLabel("Email Address"),
              _buildTextField(_emailController, "e.g. name@example.com", Icons.email_rounded),
              const SizedBox(height: 20),
              
              _buildLabel("Phone Number"),
              _buildTextField(_phoneController, "10-digit number", Icons.phone_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              
              _buildLabel("Password"),
              _buildTextField(_passwordController, "At least 6 characters", Icons.lock_rounded, isPassword: true),
              const SizedBox(height: 20),
              
              _buildLabel("Confirm Password"),
              _buildTextField(_confirmPasswordController, "Re-enter your password", Icons.lock_clock_rounded, isPassword: true),
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isLoading ? null : signup,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String role, String emoji, String subtitle) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(role, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? AppColors.primary : AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: isSelected ? AppColors.primaryDark : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
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
