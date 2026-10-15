import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/validation/delivery_settings_validator.dart';
import '../../../../shared/models/location.dart';
import '../../../../shared/services/geocoding_service.dart';
import '../../../auth/data/user_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../seller_inventory/data/product_repository.dart';

class DeliverySettingsScreen extends ConsumerStatefulWidget {
  const DeliverySettingsScreen({super.key});

  @override
  ConsumerState<DeliverySettingsScreen> createState() =>
      _DeliverySettingsScreenState();
}

class _DeliverySettingsScreenState
    extends ConsumerState<DeliverySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _countryController = TextEditingController();
  final _fastMinController = TextEditingController();
  final _fastMaxController = TextEditingController();
  final _regularMinController = TextEditingController();
  final _regularMaxController = TextEditingController();
  final _fastFeeController = TextEditingController();
  final _regularFeeController = TextEditingController();
  bool _fastEnabled = false;
  bool _regularEnabled = false;
  GeoLocation? _origin;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final user = ref.read(appUserProvider).value;
    if (user == null) return;
    final address = user.address;
    _fastEnabled = user.fastDeliveryEnabled;
    _regularEnabled = user.regularDeliveryEnabled;
    _countryController.text =
        user.deliveryCountryCode ?? (address?['countryCode'] as String? ?? '');
    _fastMinController.text = '${user.fastDeliveryMinDays ?? ''}';
    _fastMaxController.text = '${user.fastDeliveryMaxDays ?? ''}';
    _regularMinController.text = '${user.regularDeliveryMinDays ?? ''}';
    _regularMaxController.text = '${user.regularDeliveryMaxDays ?? ''}';
    _fastFeeController.text = user.fastDeliveryFee?.toString() ?? '';
    _regularFeeController.text = user.regularDeliveryFee?.toString() ?? '';
    final origin = user.deliveryOrigin;
    if (origin != null) {
      try {
        _origin = GeoLocation.fromMap(origin);
      } catch (_) {}
    }
    setState(() {});
  }

  Future<void> _captureOrigin() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _show('Enable location services before capturing the origin.');
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _show('Location permission is required to capture the delivery origin.');
      return;
    }
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _origin = GeoLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
    final geocoded = await GeocodingService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final countryCode = geocoded?.countryCode;
    if (countryCode != null && mounted) {
      setState(() => _countryController.text = countryCode);
    }
  }

  Future<void> _save() async {
    if (_origin != null && _countryController.text.trim().isEmpty) {
      final geocoded = await GeocodingService.getAddressFromCoordinates(
        _origin!.latitude,
        _origin!.longitude,
      );
      final countryCode = geocoded?.countryCode;
      if (countryCode != null) {
        _countryController.text = countryCode;
      }
    }
    if (!_formKey.currentState!.validate()) return;
    final fastMin = int.tryParse(_fastMinController.text.trim());
    final fastMax = int.tryParse(_fastMaxController.text.trim());
    final regularMin = int.tryParse(_regularMinController.text.trim());
    final regularMax = int.tryParse(_regularMaxController.text.trim());
    final fastFee = double.tryParse(_fastFeeController.text.trim());
    final regularFee = double.tryParse(_regularFeeController.text.trim());
    final validation = DeliverySettingsValidator.validate(
      fastEnabled: _fastEnabled,
      regularEnabled: _regularEnabled,
      origin: _origin,
      countryCode: _countryController.text,
      fastMinDays: fastMin,
      fastMaxDays: fastMax,
      regularMinDays: regularMin,
      regularMaxDays: regularMax,
      fastFee: fastFee,
      regularFee: regularFee,
    );
    if (validation != null) {
      _show(validation);
      return;
    }
    final user = ref.read(appUserProvider).value;
    if (user == null) return;
    setState(() => _saving = true);
    final updated = user.copyWith(
      fastDeliveryEnabled: _fastEnabled,
      regularDeliveryEnabled: _regularEnabled,
      deliveryOrigin: _origin?.toMap(),
      deliveryCountryCode: _countryController.text.trim().toUpperCase(),
      fastDeliveryMinDays: fastMin,
      fastDeliveryMaxDays: fastMax,
      regularDeliveryMinDays: regularMin,
      regularDeliveryMaxDays: regularMax,
      fastDeliveryFee: fastFee,
      regularDeliveryFee: regularFee,
    );
    final userResult = await ref
        .read(userRepositoryProvider)
        .updateUser(updated);
    var snapshotResult = userResult;
    if (userResult.isSuccess) {
      snapshotResult = await ref
          .read(productRepositoryProvider)
          .updateSellerDeliverySnapshot(
            sellerId: user.uid,
            fastEnabled: _fastEnabled,
            regularEnabled: _regularEnabled,
            countryCode: updated.deliveryCountryCode!,
            origin: updated.deliveryOrigin,
            fastMinDays: fastMin,
            fastMaxDays: fastMax,
            regularMinDays: regularMin,
            regularMaxDays: regularMax,
            fastFee: fastFee,
            regularFee: regularFee,
          );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    _show(
      snapshotResult.isSuccess
          ? 'Delivery settings saved.'
          : snapshotResult.exceptionOrNull!.message,
    );
  }

  void _show(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _countryController,
      _fastMinController,
      _fastMaxController,
      _regularMinController,
      _regularMaxController,
      _fastFeeController,
      _regularFeeController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Settings')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              title: const Text('Fast Delivery'),
              subtitle: const Text('Seller-managed delivery within 60 km'),
              value: _fastEnabled,
              onChanged: (value) => setState(() => _fastEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Regular Delivery'),
              subtitle: const Text('Seller-managed or supported shipping only'),
              value: _regularEnabled,
              onChanged: (value) => setState(() => _regularEnabled = value),
            ),
            TextFormField(
              controller: _countryController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Country code from delivery origin',
                helperText:
                    'Capture the origin to detect the country automatically.',
              ),
              validator: (value) =>
                  value == null ||
                      !RegExp(r'^[A-Za-z]{2}$').hasMatch(value.trim())
                  ? 'Use a two-letter country code'
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _captureOrigin,
              icon: const Icon(Icons.location_on_outlined),
              label: Text(
                _origin == null
                    ? 'Capture delivery origin'
                    : 'Origin: ${_origin!.latitude.toStringAsFixed(4)}, ${_origin!.longitude.toStringAsFixed(4)}',
              ),
            ),
            const SizedBox(height: 20),
            _windowFields(
              'Fast Delivery estimate',
              _fastMinController,
              _fastMaxController,
            ),
            _windowFields(
              'Regular Delivery estimate',
              _regularMinController,
              _regularMaxController,
            ),
            _feeField('Fast Delivery fee', _fastFeeController),
            _feeField('Regular Delivery fee', _regularFeeController),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save delivery settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _windowFields(
    String label,
    TextEditingController min,
    TextEditingController max,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: min,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '$label min days'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: max,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: '$label max days'),
          ),
        ),
      ],
    );
  }

  Widget _feeField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: '$label (optional)'),
    );
  }
}
