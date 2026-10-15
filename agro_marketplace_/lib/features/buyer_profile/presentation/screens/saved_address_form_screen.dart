import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/validation/delivery_address_validator.dart';
import '../../../../shared/models/address.dart';
import '../../../../shared/models/detailed_address.dart';
import '../../../../shared/models/location.dart';
import '../../../../shared/services/geocoding_service.dart';
import '../../../auth/data/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SavedAddressFormScreen extends ConsumerStatefulWidget {
  final int? index;

  const SavedAddressFormScreen({super.key, this.index});

  @override
  ConsumerState<SavedAddressFormScreen> createState() =>
      _SavedAddressFormScreenState();
}

class _SavedAddressFormScreenState
    extends ConsumerState<SavedAddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipient = TextEditingController();
  final _phone = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _country = TextEditingController(text: 'IN');
  double? _latitude;
  double? _longitude;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(appUserProvider).value;
      final addresses = user?.savedAddresses ?? const <Map<String, dynamic>>[];
      if (widget.index != null && widget.index! < addresses.length) {
        final saved = DetailedAddress.fromMap(addresses[widget.index!]);
        _recipient.text = saved.recipientName ?? '';
        _phone.text = saved.phoneNumber ?? '';
        _line1.text = saved.address.line1 ?? '';
        _line2.text = saved.address.line2 ?? '';
        _city.text = saved.address.city ?? '';
        _state.text = saved.address.state;
        _pincode.text = saved.address.pincode;
        _country.text = saved.address.countryCode ?? '';
        _latitude = saved.location?.latitude;
        _longitude = saved.location?.longitude;
      }
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _recipient,
      _phone,
      _line1,
      _line2,
      _city,
      _state,
      _pincode,
      _country,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception(
          'Location services are unavailable. You can save this address without coordinates.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission was not granted. You can save this address without coordinates.',
        );
      }
      setState(() => _loading = true);
      final position = await Geolocator.getCurrentPosition();
      _latitude = position.latitude;
      _longitude = position.longitude;
      final geocoded = await GeocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (geocoded != null) {
        _line1.text = geocoded.line1 ?? _line1.text;
        _city.text = geocoded.village ?? geocoded.district ?? _city.text;
        _state.text = geocoded.state ?? _state.text;
        _pincode.text = geocoded.pincode ?? _pincode.text;
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location captured.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final address = DetailedAddress(
      recipientName: _recipient.text.trim(),
      phoneNumber: _phone.text.trim(),
      address: Address(
        line1: _line1.text.trim(),
        line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        pincode: _pincode.text.trim(),
        countryCode: _country.text.trim(),
      ),
      location: _latitude != null && _longitude != null
          ? GeoLocation(latitude: _latitude!, longitude: _longitude!)
          : null,
    );
    final validation = DeliveryAddressValidator.validate(address);
    if (!validation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all address fields with valid values.',
          ),
        ),
      );
      return;
    }
    final user = ref.read(appUserProvider).value;
    if (user == null) return;
    setState(() => _loading = true);
    final addresses = List<Map<String, dynamic>>.from(user.savedAddresses);
    if (widget.index == null) {
      addresses.add(address.toMap());
    } else if (widget.index! < addresses.length) {
      addresses[widget.index!] = address.toMap();
    }
    final result = await ref
        .read(userRepositoryProvider)
        .updateUser(user.copyWith(savedAddresses: addresses));
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.exceptionOrNull?.message ?? 'Could not save address',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null ? 'Add Address' : 'Edit Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_recipient, 'Recipient name'),
            _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
            _field(_line1, 'Address line 1'),
            _field(_line2, 'Address line 2 (optional)'),
            _field(_city, 'City / town'),
            _field(_state, 'State / region'),
            _field(_pincode, 'Postal code', keyboardType: TextInputType.number),
            _field(_country, 'Country code (e.g. IN)'),
            OutlinedButton.icon(
              onPressed: _loading ? null : _captureLocation,
              icon: const Icon(Icons.my_location),
              label: Text(
                _latitude == null
                    ? 'Capture location (optional)'
                    : 'Location captured',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save address'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coordinates are optional for Regular Delivery. Without them, this address cannot be used for Fast Delivery.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            label.contains('optional') || label.contains('line 2')
            ? null
            : (value == null || value.trim().isEmpty ? 'Required' : null),
      ),
    );
  }
}
