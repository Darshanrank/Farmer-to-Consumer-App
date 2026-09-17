import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import '../providers/inventory_providers.dart';
import '../providers/product_form_controller.dart';

class AddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId;

  const AddEditProductScreen({
    super.key,
    this.productId,
  });

  @override
  ConsumerState<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends ConsumerState<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  Product? _existingProduct;
  
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _brandController;
  late final TextEditingController _moqController;

  String _selectedCategory = 'Seeds';
  String _selectedUnit = 'kg';
  String _selectedStatus = 'active';

  List<ProductImage> _existingImages = [];
  final List<File> _newImagesToUpload = [];

  final _categories = ['Seeds', 'Fertilizers', 'Crop Protection', 'Machinery & Equipment', 'Irrigation', 'Tools', 'Other'];
  final _units = ['kg', 'liter', 'piece', 'gram', 'ml', 'ton'];
  final _statuses = ['active', 'outOfStock', 'hidden'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _brandController = TextEditingController();
    _moqController = TextEditingController(text: '1');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.productId != null && _existingProduct == null) {
      // Find the product from the stream provider
      final productsAsync = ref.read(sellerProductsProvider);
      final products = productsAsync.value ?? [];
      
      try {
        _existingProduct = products.firstWhere((p) => p.id == widget.productId);
        _nameController.text = _existingProduct!.name;
        _descriptionController.text = _existingProduct!.description;
        _priceController.text = _existingProduct!.price.toString();
        _stockController.text = _existingProduct!.stockQuantity.toString();
        _brandController.text = _existingProduct!.brand ?? '';
        _moqController.text = _existingProduct!.minOrderQuantity.toString();
        
        setState(() {
          _selectedCategory = _categories.contains(_existingProduct!.category) ? _existingProduct!.category : 'Other';
          _selectedUnit = _units.contains(_existingProduct!.unit) ? _existingProduct!.unit : 'kg';
          _selectedStatus = _statuses.contains(_existingProduct!.status) ? _existingProduct!.status : 'active';
          _existingImages = List.from(_existingProduct!.images);
        });
      } catch (e) {
        // Product not found (maybe deleted or link invalid)
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _moqController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    
    if (images.isNotEmpty) {
      for (var img in images) {
        final length = await img.length();
        if (length > 250 * 1024) { // 250 KB limit
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Image ${img.name} is too large (${(length/1024).toStringAsFixed(1)} KB). Max is 250 KB.'),
                 backgroundColor: Colors.red,
               ),
             );
          }
          continue;
        }
        setState(() {
          _newImagesToUpload.add(File(img.path));
        });
      }
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImagesToUpload.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Require at least one image
    if (_existingImages.isEmpty && _newImagesToUpload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await ref.read(productFormControllerProvider.notifier).submit(
      existingProduct: _existingProduct,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      unit: _selectedUnit,
      stockQuantity: int.parse(_stockController.text.trim()),
      category: _selectedCategory,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      minOrderQuantity: int.tryParse(_moqController.text.trim()) ?? 1,
      attributes: _existingProduct?.attributes ?? {},
      existingImages: _existingImages,
      newImagesToUpload: _newImagesToUpload,
      status: _selectedStatus,
    );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (result.isFailure && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.exceptionOrNull.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormControllerProvider);
    final isLoading = state.isLoading;
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photos Section
              Text('Product Images', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Button
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Add', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Existing Images
                    for (int i = 0; i < _existingImages.length; i++)
                      _buildImagePreview(
                        child: Image.memory(
                          _existingImages[i].data,
                          fit: BoxFit.cover,
                        ),
                        onRemove: () => _removeExistingImage(i),
                      ),

                    // New Images
                    for (int i = 0; i < _newImagesToUpload.length; i++)
                      _buildImagePreview(
                        child: Image.file(
                          _newImagesToUpload[i],
                          fit: BoxFit.cover,
                        ),
                        onRemove: () => _removeNewImage(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock Qty',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (int.tryParse(val) == null || int.parse(val) < 0) return 'Invalid stock';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand / Manufacturer',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _moqController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Order Qty',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Required';
                        if (int.tryParse(val) == null || int.parse(val) < 1) return 'Must be >= 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatus = val);
                },
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isEditing ? 'Save Changes' : 'Add Product',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview({required Widget child, required VoidCallback onRemove}) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
