// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show base64Encode;
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/screens/seller/seller_dashboard.dart';
import 'package:intl/intl.dart';
import 'package:kisanbazaar/utils/app_categories.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _originalPriceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = AppCategories.selectable.map((c) => c.title).toList();

  String _selectedUnit = '/kg';
  final List<String> _units = ['/kg', '/liter', '/gm', '/dozen', '/pc'];

  Uint8List? _imageBytes;
  final picker = ImagePicker();
  bool _isLoading = false;
  bool _showSuccessAnimation = false;

  late AnimationController _successController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = CurvedAnimation(parent: _successController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _harvestDateController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 600, maxHeight: 600);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _harvestDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please upload a product image"), backgroundColor: AppColors.error));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category"), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final String sellerId = currentUser?.uid ?? 'seller_${DateTime.now().millisecondsSinceEpoch}';
      String sellerName = 'Kisan Farmer';
      if (currentUser != null) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get().timeout(const Duration(seconds: 4));
          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;
            if (data != null && data['fullName'] != null && data['fullName'].toString().trim().isNotEmpty) {
              sellerName = data['fullName'].toString();
            }
          }
        } catch (_) {}
      }

      String imageUrl = '';
      try {
        final storageRef = FirebaseStorage.instance.ref().child('product_images').child('${DateTime.now().millisecondsSinceEpoch}_$sellerId.jpg');
        final uploadTask = storageRef.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
        final snapshot = await uploadTask.timeout(const Duration(seconds: 4));
        imageUrl = await snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 4));
      } catch (e) {
        try {
          String base64String = base64Encode(_imageBytes!);
          if (base64String.length > 800000) throw Exception('Image is too large. Please select a smaller image.');
          imageUrl = base64String;
        } catch (fallbackError) {
          throw Exception('Failed to process image: $e\nFallback error: $fallbackError');
        }
      }

      final double? parsedPrice = double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''));
      final double? parsedOriginalPrice = double.tryParse(_originalPriceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''));
      final int? parsedQuantity = int.tryParse(_quantityController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));

      if (parsedPrice == null || parsedPrice <= 0) throw Exception('Invalid price value.');
      if (parsedQuantity == null || parsedQuantity <= 0) throw Exception('Invalid quantity value.');

      final Map<String, dynamic> productData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': parsedPrice,
        'unit': _selectedUnit,
        'quantity': parsedQuantity,
        'category': _selectedCategory ?? 'Other',
        'seller_name': sellerName,
        'imageUrl': imageUrl,
        'image': imageUrl, 
        'sellerId': sellerId,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (parsedOriginalPrice != null && parsedOriginalPrice > parsedPrice) productData['originalPrice'] = parsedOriginalPrice;
      if (_harvestDateController.text.trim().isNotEmpty) productData['harvest_date'] = _harvestDateController.text.trim();

      await FirebaseFirestore.instance.collection('products').add(productData).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _showSuccessAnimation = true;
      });

      _successController.forward();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _showSuccessAnimation = false;
        _successController.reset();
        _nameController.clear();
        _descriptionController.clear();
        _priceController.clear();
        _originalPriceController.clear();
        _quantityController.clear();
        _harvestDateController.clear();
        _selectedCategory = null;
        _selectedUnit = '/kg';
        _imageBytes = null;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SellerDashboard()), (route) => false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString().replaceAll('Exception: ', '')}"), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Add New Product", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _imageBytes == null ? AppColors.divider : AppColors.primary, width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: _imageBytes == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary),
                                ),
                                const SizedBox(height: 16),
                                const Text("Upload Product Photo", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
                                const SizedBox(height: 4),
                                const Text("High-quality images sell faster", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel("Product Name *"),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration("e.g. Premium Wheat Seeds"),
                    validator: (value) => value!.isEmpty ? "Enter product name" : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Category *"),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedCategory,
                              decoration: _inputDecoration("Select"),
                              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => _selectedCategory = val),
                              validator: (value) => value == null ? "Select" : null,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Unit *"),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedUnit,
                              decoration: _inputDecoration("Unit"),
                              items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u, overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => _selectedUnit = val!),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Selling Price *"),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration("0.00").copyWith(prefixText: "₹ ", prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              validator: (value) => value!.isEmpty ? "Req" : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Quantity *"),
                            TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration("e.g. 50"),
                              validator: (value) => value!.isEmpty ? "Req" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Original Price (Opt)"),
                            TextFormField(
                              controller: _originalPriceController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration("0.00").copyWith(prefixText: "₹ ", prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Harvest Date (Opt)"),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _harvestDateController,
                                  decoration: _inputDecoration("Select date").copyWith(suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("Description *"),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: _inputDecoration("Describe your product concisely..."),
                    validator: (value) => value!.isEmpty ? "Enter description" : null,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _uploadProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text("Publish Product", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          if (_showSuccessAnimation)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      const Text("Product Published!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
    );
  }
}
