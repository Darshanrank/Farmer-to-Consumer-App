import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisanbazaar/screens/auth/login_screen.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/services/auth_service.dart';
import 'package:kisanbazaar/screens/buyer/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  final TextEditingController _mobileController = TextEditingController();

  String? name, email, imageUrl;
  bool isLoading = true;

  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        final user = await _authService.getUserModel(userId);
        if (user != null && mounted) {
          setState(() {
            name = user.fullName;
            email = user.email;
            _mobileController.text = user.phone;
            imageUrl = user.imageUrl ?? '';
            isLoading = false;

            if (user.addresses.isNotEmpty) {
              _addresses = user.addresses.map((a) => a.toJson()).toList();
            } else {
              String legacyAddress = user.address ?? '';
              String legacyPhone = user.phone;
              if (legacyAddress.isNotEmpty) {
                _addresses = [
                  {
                    'label': 'Home',
                    'address': legacyAddress,
                    'phone': legacyPhone,
                    'isDefault': true,
                  }
                ];
              }
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
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
      setState(() => imageUrl = downloadUrl);
    }
  }

  Future<void> _saveProfile() async {
    try {
      String userId = _auth.currentUser!.uid;
      String defaultAddress = '';
      for (var addr in _addresses) {
        if (addr['isDefault'] == true) {
          defaultAddress = addr['address'] ?? '';
          break;
        }
      }
      if (defaultAddress.isEmpty && _addresses.isNotEmpty) {
        defaultAddress = _addresses.first['address'] ?? '';
      }

      await _authService.updateProfile(
        userId,
        phone: _mobileController.text,
        defaultAddress: defaultAddress,
        addresses: _addresses,
      );
      
      Fluttertoast.showToast(msg: "Profile updated successfully!", backgroundColor: AppColors.primary);
    } catch (e) {
      Fluttertoast.showToast(msg: "Update failed: $e", backgroundColor: Colors.red);
    }
  }

  Future<void> _saveAddressesToFirestore() async {
    try {
      String userId = _auth.currentUser!.uid;
      await _authService.updateUserAddresses(userId, _addresses);
    } catch (e) {
      debugPrint('Error auto-saving addresses: $e');
    }
  }

  void _showAddEditAddressDialog({Map<String, dynamic>? existing, int? index}) {
    final bool isEditing = existing != null && index != null;
    final labelController = TextEditingController(text: existing?['label'] ?? '');
    final addressController = TextEditingController(text: existing?['address'] ?? '');
    final phoneController = TextEditingController(text: existing?['phone'] ?? _mobileController.text);
    bool isDefault = existing?['isDefault'] ?? (_addresses.isEmpty);

    final labels = ['Home', 'Office', 'Work', 'Other'];
    String selectedLabel = existing?['label'] ?? 'Home';
    if (!labels.contains(selectedLabel)) {
      selectedLabel = 'Other';
      labelController.text = existing?['label'] ?? '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isEditing ? "Edit ${existing['label'] ?? 'Address'}" : "Add New Address",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    const Text("Address Type", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    if (isEditing)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              selectedLabel == 'Home' ? Icons.home_rounded
                                  : selectedLabel == 'Office' || selectedLabel == 'Work' ? Icons.business_rounded
                                  : Icons.location_on_rounded,
                              size: 18, color: AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(existing['label'] ?? selectedLabel, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const SizedBox(width: 6),
                            Icon(Icons.lock_outline, size: 14, color: Colors.grey[400]),
                          ],
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: labels.map((label) {
                          bool selected = selectedLabel == label;
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primary : Colors.grey[700],
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (val) => setModalState(() => selectedLabel = label),
                          );
                        }).toList(),
                      ),
                    if (!isEditing && selectedLabel == 'Other') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: labelController,
                        decoration: InputDecoration(
                          labelText: "Custom Label",
                          prefixIcon: const Icon(Icons.label_outline, color: AppColors.primary),
                          filled: true, fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    TextField(
                      controller: addressController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Full Address *",
                        prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 40), child: Icon(Icons.location_on_rounded, color: AppColors.primary)),
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      value: isDefault,
                      onChanged: (val) => setModalState(() => isDefault = val ?? false),
                      title: const Text("Set as default address", style: TextStyle(fontWeight: FontWeight.w500)),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (addressController.text.trim().isEmpty) {
                            Fluttertoast.showToast(msg: "Please enter an address");
                            return;
                          }

                          String finalLabel;
                          if (isEditing) {
                            finalLabel = existing['label'] ?? selectedLabel;
                          } else {
                            finalLabel = selectedLabel == 'Other'
                                ? (labelController.text.trim().isEmpty ? 'Other' : labelController.text.trim())
                                : selectedLabel;
                          }

                          final newAddress = {
                            'label': finalLabel,
                            'address': addressController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'isDefault': isDefault,
                          };

                          setState(() {
                            if (isDefault) {
                              for (var addr in _addresses) {
                                addr['isDefault'] = false;
                              }
                            }

                            if (isEditing) {
                              _addresses[index] = newAddress;
                            } else {
                              _addresses.add(newAddress);
                            }

                            if (!_addresses.any((a) => a['isDefault'] == true) && _addresses.isNotEmpty) {
                              _addresses.first['isDefault'] = true;
                            }
                          });

                          _saveAddressesToFirestore();
                          Navigator.pop(context);
                          Fluttertoast.showToast(msg: isEditing ? "Address updated!" : "Address added!", backgroundColor: AppColors.primary);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          isEditing ? "Update Address" : "Add Address",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Delete Address", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Remove \"${_addresses[index]['label']}\" address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() {
                bool wasDefault = _addresses[index]['isDefault'] == true;
                _addresses.removeAt(index);
                if (wasDefault && _addresses.isNotEmpty) {
                  _addresses.first['isDefault'] = true;
                }
              });
              _saveAddressesToFirestore();
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Address deleted", backgroundColor: AppColors.error);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('buyer_selectedIndex');
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: AppColors.divider)
                    ),
                    child: _buildTextField(_mobileController, "Mobile Number", Icons.phone_rounded),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("My Addresses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      TextButton.icon(
                        onPressed: () => _showAddEditAddressDialog(),
                        icon: const Icon(Icons.add_circle, size: 20, color: AppColors.primary),
                        label: const Text("Add", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_addresses.isEmpty)
                    GestureDetector(
                      onTap: () => _showAddEditAddressDialog(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.add_location_alt_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text("No addresses added yet", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text("Tap to add your first delivery address", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...List.generate(_addresses.length, (index) => _buildAddressCard(_addresses[index], index)),

                  const SizedBox(height: 32),
                  const Text("Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: AppColors.divider)
                    ),
                    child: Column(
                      children: [
                        _buildOptionTile(Icons.shopping_bag_rounded, "My Orders", () {}),
                        const Divider(height: 1),
                        _buildOptionTile(Icons.notifications_rounded, "Notifications", () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                        }),
                        const Divider(height: 1),
                        _buildOptionTile(Icons.help_center_rounded, "Help Center", () {}),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3)
                    ),
                    child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _logout,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
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

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: Colors.white,
                  backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person_rounded, size: 56, color: AppColors.primary) : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(name ?? "User", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(email ?? "", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr, int index) {
    bool isDefault = addr['isDefault'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDefault ? AppColors.primaryLight.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? AppColors.primary.withValues(alpha: 0.5) : AppColors.divider,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDefault ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
                  shape: BoxShape.circle
                ),
                child: Icon(
                  addr['label'] == 'Home' ? Icons.home_rounded : addr['label'] == 'Office' || addr['label'] == 'Work' ? Icons.business_rounded : Icons.location_on_rounded,
                  color: isDefault ? AppColors.primary : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                addr['label'] ?? 'Address',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDefault ? AppColors.primary : AppColors.textPrimary),
              ),
              if (isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Default", style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: Colors.grey[400]),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditAddressDialog(existing: addr, index: index);
                  } else if (value == 'delete') {
                    _deleteAddress(index);
                  } else if (value == 'default') {
                    setState(() {
                      for (var a in _addresses) {
                        a['isDefault'] = false;
                      }
                      _addresses[index]['isDefault'] = true;
                    });
                    _saveAddressesToFirestore();
                    Fluttertoast.showToast(msg: "${addr['label']} set as default", backgroundColor: AppColors.primary);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!isDefault) const PopupMenuItem(value: 'default', child: Text('Set as Default')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(addr['address'] ?? '', style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 14)),
          if (addr['phone'] != null && addr['phone'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("📞 ${addr['phone']}", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}
