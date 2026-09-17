import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _businessNameController = TextEditingController();

  bool _isLoading = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback or wait for the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(appUserProvider).value;
      if (user != null) {
        setState(() {
          _user = user;
          _nameController.text = user.displayName ?? '';
          _phoneController.text = user.phone ?? '';
          _addressController.text = user.address ?? '';
          _businessNameController.text = user.businessName ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isSeller = _user!.role == 'seller';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full Name',
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              
              if (isSeller) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Business Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Farm / Business Name',
                  controller: _businessNameController,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
              ],
              
              const SizedBox(height: 32),
              AppButton(
                label: 'Save Changes',
                isLoading: _isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);
                  try {
                    final updatedUser = _user!.copyWith(
                      displayName: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: _addressController.text.trim(),
                      businessName: isSeller ? _businessNameController.text.trim() : null,
                    );
                    
                    await ref.read(userRepositoryProvider).updateUser(updatedUser);
                    
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated successfully')));
                    context.pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
