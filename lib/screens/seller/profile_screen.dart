import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kisanbazaar/screens/auth/login_screen.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();

  String? name, email, imageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          setState(() {
            final data = userDoc.data() as Map<String, dynamic>?;
            name = data?['fullName'];
            email = data?['email'];
            _mobileController.text = data?['phone'] ?? '';
            _shopNameController.text = data?['shopName'] ?? '';
            _shopAddressController.text = data?['shopAddress'] ?? '';
            imageUrl = data?['image'] ?? '';
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String userId = _auth.currentUser!.uid;
      Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');

      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(userId).update({'image': downloadUrl});
      setState(() {
        imageUrl = downloadUrl;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(userId).update({
        'phone': _mobileController.text,
        'shopName': _shopNameController.text,
        'shopAddress': _shopAddressController.text,
      });

      Fluttertoast.showToast(msg: "Profile updated successfully!", backgroundColor: AppColors.success, textColor: Colors.white);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to update profile", backgroundColor: AppColors.error, textColor: Colors.white);
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('seller_selectedIndex');
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error logging out", backgroundColor: AppColors.error, textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header Profile Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)]),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
                          child: (imageUrl == null || imageUrl!.isEmpty) ? Text(name?.substring(0, 1).toUpperCase() ?? '?', style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(name ?? 'Seller', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text(email ?? 'No email provided', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            
            // Editable Form Area
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Shop Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  
                  _buildTextField(controller: _shopNameController, label: "Shop Name", icon: Icons.storefront_rounded),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _mobileController, label: "Mobile Number", icon: Icons.phone_rounded, isPhone: true),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _shopAddressController, label: "Shop Address", icon: Icons.location_on_rounded),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                      label: const Text("Logout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.error, letterSpacing: 0.5)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool isPhone = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13, letterSpacing: 0.5)),
        ),
        TextField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }
}
