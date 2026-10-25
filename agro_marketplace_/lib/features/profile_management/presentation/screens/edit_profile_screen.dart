import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../shared/models/address.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../../shared/models/location.dart';
import '../../../../shared/services/geocoding_service.dart';
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
  final _businessNameController = TextEditingController();

  // Structured address controllers
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _villageController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;
  AppUser? _user;

  // Geo-location state
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromProvider();
    });
  }

  void _initFromProvider() {
    final user = ref.read(appUserProvider).value;
    if (user != null && !_isInitialized) {
      _populateForm(user);
    }
  }

  void _populateForm(AppUser user) {
    setState(() {
      _user = user;
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phone ?? '';
      _businessNameController.text = user.businessName ?? '';

      // Parse structured address
      if (user.address != null) {
        try {
          final detailed = DetailedAddress.fromMap(user.address!);
          _line1Controller.text = detailed.address.line1 ?? '';
          _line2Controller.text = detailed.address.line2 ?? '';
          _landmarkController.text = detailed.address.landmark ?? '';
          _villageController.text = detailed.address.village ?? '';
          _talukaController.text = detailed.address.taluka ?? '';
          _districtController.text = detailed.address.district ?? '';
          _stateController.text = detailed.address.state;
          _pincodeController.text = detailed.address.pincode;
          _latitude = detailed.location?.latitude;
          _longitude = detailed.location?.longitude;
        } catch (_) {
          // Fallback: if parsing fails, clear all fields
        }
      }

      _isInitialized = true;
    });
  }

  Future<void> _pickCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Please enable them.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permissions are denied.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permissions are permanently denied. Please enable in settings.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() => _isLocating = true);

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Reverse geocode to auto-fill address fields
      final geocoded = await GeocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      bool addressUpdated = false;
      if (geocoded != null) {
        setState(() {
          if (geocoded.line1 != null && geocoded.line1!.isNotEmpty) {
            _line1Controller.text = geocoded.line1!;
            addressUpdated = true;
          }
          if (geocoded.line2 != null && geocoded.line2!.isNotEmpty) {
            _line2Controller.text = geocoded.line2!;
            addressUpdated = true;
          }
          if (geocoded.landmark != null && geocoded.landmark!.isNotEmpty) {
            _landmarkController.text = geocoded.landmark!;
          }
          if (geocoded.village != null && geocoded.village!.isNotEmpty) {
            _villageController.text = geocoded.village!;
            addressUpdated = true;
          }
          if (geocoded.taluka != null && geocoded.taluka!.isNotEmpty) {
            _talukaController.text = geocoded.taluka!;
            addressUpdated = true;
          }
          if (geocoded.district != null && geocoded.district!.isNotEmpty) {
            _districtController.text = geocoded.district!;
            addressUpdated = true;
          }
          if (geocoded.state != null && geocoded.state!.isNotEmpty) {
            _stateController.text = geocoded.state!;
            addressUpdated = true;
          }
          if (geocoded.pincode != null && geocoded.pincode!.isNotEmpty) {
            _pincodeController.text = geocoded.pincode!;
            addressUpdated = true;
          }
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              addressUpdated
                  ? 'Location & address auto-filled successfully!'
                  : 'Location captured: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to user changes and populate form if not yet initialized
    ref.listen(appUserProvider, (_, next) {
      if (!_isInitialized && next.value != null) {
        _populateForm(next.value!);
      }
    });

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isSeller = _user!.isSeller;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // === Address Section ===
              Text(
                'Address',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Address Line 1',
                hint: 'House/Shop No., Street',
                controller: _line1Controller,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Address Line 2 (Optional)',
                hint: 'Area, Colony',
                controller: _line2Controller,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Landmark (Optional)',
                hint: 'Near temple, school, etc.',
                controller: _landmarkController,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Village / Town',
                      controller: _villageController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Taluka',
                      controller: _talukaController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(label: 'District', controller: _districtController),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'State',
                      controller: _stateController,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Pincode',
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Required';
                        }
                        if (val.trim().length != 6) return '6-digit pincode';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // === GPS Location Section ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'GPS Location (Optional)',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adding your location helps with nearby product discovery.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    if (_latitude != null && _longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: _isLocating ? null : _pickCurrentLocation,
                      icon: _isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed),
                      label: Text(
                        _isLocating
                            ? 'Fetching Address...'
                            : (_latitude != null
                                  ? 'Update Location & Address'
                                  : 'Pick Current Location'),
                      ),
                    ),
                  ],
                ),
              ),

              // Only show business section for sellers
              if (isSeller) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Business Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Farm / Business Name',
                  controller: _businessNameController,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
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
                    // Build structured address
                    final address = Address(
                      line1: _line1Controller.text.trim().isEmpty
                          ? null
                          : _line1Controller.text.trim(),
                      line2: _line2Controller.text.trim().isEmpty
                          ? null
                          : _line2Controller.text.trim(),
                      landmark: _landmarkController.text.trim().isEmpty
                          ? null
                          : _landmarkController.text.trim(),
                      village: _villageController.text.trim().isEmpty
                          ? null
                          : _villageController.text.trim(),
                      taluka: _talukaController.text.trim().isEmpty
                          ? null
                          : _talukaController.text.trim(),
                      district: _districtController.text.trim().isEmpty
                          ? null
                          : _districtController.text.trim(),
                      state: _stateController.text.trim(),
                      pincode: _pincodeController.text.trim(),
                    );

                    // Preserve existing location if any
                    DetailedAddress? existingDetailed;
                    if (_user!.address != null) {
                      try {
                        existingDetailed = DetailedAddress.fromMap(
                          _user!.address!,
                        );
                      } catch (_) {}
                    }

                    // Use newly picked location or preserve existing
                    GeoLocation? location;
                    if (_latitude != null && _longitude != null) {
                      location = GeoLocation(
                        latitude: _latitude!,
                        longitude: _longitude!,
                      );
                    } else {
                      location = existingDetailed?.location;
                    }

                    final detailedAddress = DetailedAddress(
                      address: address,
                      location: location,
                    );

                    final updatedUser = _user!.copyWith(
                      displayName: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: detailedAddress.toMap(),
                      businessName: isSeller
                          ? _businessNameController.text.trim()
                          : _user!.businessName, // preserve existing for non-sellers
                    );

                    final result = await ref
                        .read(userRepositoryProvider)
                        .updateUser(updatedUser);

                    if (!context.mounted) return;

                    if (result.isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error: ${result.exceptionOrNull?.message}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
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
