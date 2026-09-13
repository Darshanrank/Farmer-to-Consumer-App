// ignore_for_file: use_build_context_synchronously

import 'dart:convert' show base64Encode;
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/utils/app_categories.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({super.key, required this.productId, required this.productData});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _sellerNameController;
  late TextEditingController _descriptionController;

  String? _selectedCategory;
  final List<String> _categories = AppCategories.selectable.map((c) => c.title).toList();

  String _selectedUnit = '/kg';
  final List<String> _units = ['/kg', '/liter', '/gm', '/dozen', '/pc'];

  Uint8List? _imageBytes;
  String? _existingImageUrl;
  final picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.productData['name'] ?? '');
    _priceController = TextEditingController(text: widget.productData['price']?.toString() ?? '');
    _originalPriceController = TextEditingController(text: widget.productData['originalPrice']?.toString() ?? '');
    _quantityController = TextEditingController(text: widget.productData['quantity']?.toString() ?? '');
    _sellerNameController = TextEditingController(text: widget.productData['seller_name'] ?? '');
    _descriptionController = TextEditingController(text: widget.productData['description'] ?? '');
    _existingImageUrl = widget.productData['imageUrl'] ?? widget.productData['image'];

    // Safely parse category
    String cat = widget.productData['category'] ?? '';
    if (_categories.contains(cat)) {
      _selectedCategory = cat;
    } else if (cat.isNotEmpty && _categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }

    // Safely parse unit
    String unt = widget.productData['unit'] ?? '';
    if (_units.contains(unt)) {
      _selectedUnit = unt;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _sellerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxWidth: 600, maxHeight: 600);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _existingImageUrl = null;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please ensure an image is selected"), backgroundColor: AppColors.error));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a category"), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _existingImageUrl ?? '';
      String finalImageBase64Fallback = widget.productData['image'] ?? '';

      if (_imageBytes != null) {
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          final storageRef = FirebaseStorage.instance.ref().child('product_images').child('${DateTime.now().millisecondsSinceEpoch}_${currentUser?.uid ?? 'unknown'}.jpg');
          final uploadTask = storageRef.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
          final snapshot = await uploadTask.timeout(const Duration(seconds: 4));
          finalImageUrl = await snapshot.ref.getDownloadURL().timeout(const Duration(seconds: 4));
          finalImageBase64Fallback = finalImageUrl;
        } catch (e) {
          try {
            String base64String = base64Encode(_imageBytes!);
            if (base64String.length > 800000) throw Exception('Image too large. Please select a smaller image.');
            finalImageUrl = base64String;
            finalImageBase64Fallback = base64String;
          } catch (fallbackError) {
            throw Exception('Failed to upload new image: $e');
          }
        }
      }

      final double? parsedPrice = double.tryParse(_priceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''));
      final double? parsedOriginalPrice = double.tryParse(_originalPriceController.text.trim().replaceAll(RegExp(r'[^0-9.]'), ''));
      final int? parsedQuantity = int.tryParse(_quantityController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''));

      if (parsedPrice == null || parsedPrice <= 0) throw Exception('Invalid price.');
      if (parsedQuantity == null || parsedQuantity <= 0) throw Exception('Invalid quantity.');

      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': parsedPrice,
        'quantity': parsedQuantity,
        'unit': _selectedUnit,
        'category': _selectedCategory,
        'seller_name': _sellerNameController.text.trim(),
        'imageUrl': finalImageUrl,
        'image': finalImageBase64Fallback,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (parsedOriginalPrice != null && parsedOriginalPrice > parsedPrice) {
        updateData['originalPrice'] = parsedOriginalPrice;
      } else {
        updateData['originalPrice'] = FieldValue.delete();
      }

      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(updateData).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product updated successfully"), backgroundColor: AppColors.success));
      Navigator.pop(context, true);
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
        title: const Text("Edit Product", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                    border: Border.all(color: (_imageBytes == null && _existingImageUrl == null) ? AppColors.error : AppColors.divider, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: _imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              Positioned(top: 12, right: 12, child: _buildEditIcon()),
                            ],
                          ),
                        )
                      : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                children: [
                                  KisanImage(imageSource: _existingImageUrl!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                                  Positioned(top: 12, right: 12, child: _buildEditIcon()),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.add_photo_alternate_rounded, size: 48, color: AppColors.primary),
                                ),
                                const SizedBox(height: 16),
                                const Text("Upload Product Photo", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
                              ],
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

              _buildLabel("Original Price (Opt)"),
              TextFormField(
                controller: _originalPriceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("0.00").copyWith(prefixText: "₹ ", prefixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              
              _buildLabel("Description (Opt)"),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Describe your product concisely..."),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
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
