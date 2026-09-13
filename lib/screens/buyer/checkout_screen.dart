import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/services/auth_service.dart';
import 'package:kisanbazaar/services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = "Cash on Delivery";
  int _selectedAddressIndex = 0;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();

  List<Map<String, dynamic>> _addresses = [];
  String _userPhone = "";
  String _buyerName = "";
  String _buyerPhone = "";

  @override
  void initState() {
    super.initState();
    _fetchUserAddresses();
  }

  Future<void> _fetchUserAddresses() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final user = await _authService.getUserModel(userId);
        if (user != null && mounted) {
          setState(() {
            _userPhone = user.phone;
            _buyerName = user.fullName;
            _buyerPhone = user.phone;

            if (user.addresses.isNotEmpty) {
              _addresses = user.addresses.map((a) => a.toJson()).toList();
              for (int i = 0; i < _addresses.length; i++) {
                if (_addresses[i]['isDefault'] == true) {
                  _selectedAddressIndex = i;
                  break;
                }
              }
            } else {
              String legacyAddress = user.address ?? '';
              if (legacyAddress.isNotEmpty) {
                _addresses = [
                  {
                    'label': 'Home',
                    'address': legacyAddress,
                    'phone': _userPhone,
                    'isDefault': true,
                  }
                ];
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
    }
  }

  String _getSelectedDeliveryAddress() {
    if (_addresses.isEmpty) return 'No address set';
    final addr = _addresses[_selectedAddressIndex];
    String fullAddress = addr['address'] ?? '';
    String phone = addr['phone'] ?? _userPhone;
    if (phone.isNotEmpty) {
      fullAddress += '\n$phone';
    }
    return fullAddress;
  }

  void _showAddAddressBottomSheet() {
    final addressController = TextEditingController();
    final phoneController = TextEditingController(text: _userPhone);
    String selectedLabel = 'Home';
    final labels = ['Home', 'Office', 'Work', 'Other'];
    final customLabelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                    const Text("Add New Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    const Text("Address Type", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
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
                    if (selectedLabel == 'Other') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: customLabelController,
                        decoration: InputDecoration(
                          labelText: "Custom Label",
                          hintText: "e.g. Grandma's House",
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
                        hintText: "House No, Street, City, PIN",
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.location_on_rounded, color: AppColors.primary),
                        ),
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
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter an address"), backgroundColor: AppColors.error),
                            );
                            return;
                          }

                          String finalLabel = selectedLabel == 'Other'
                              ? (customLabelController.text.trim().isEmpty ? 'Other' : customLabelController.text.trim())
                              : selectedLabel;

                          final newAddress = {
                            'label': finalLabel,
                            'address': addressController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'isDefault': _addresses.isEmpty,
                          };

                          setState(() {
                            _addresses.add(newAddress);
                            _selectedAddressIndex = _addresses.length - 1;
                          });

                          try {
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            if (userId != null) {
                              await _authService.updateUserAddresses(userId, _addresses);
                            }
                          } catch (e) {
                            debugPrint('Error saving address: $e');
                          }

                          if (context.mounted) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Add & Use This Address", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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

  Future<void> placeOrder() async {
    if (widget.totalAmount <= 0) return;
    if (_addresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a delivery address first"), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    await _processOrder();
  }

  Future<void> _processOrder() async {
    try {
      String? buyerId = FirebaseAuth.instance.currentUser?.uid;
      if (buyerId == null) throw Exception("User not logged in");

      String deliveryAddress = _getSelectedDeliveryAddress();

      await _orderService.placeOrder(
        buyerId: buyerId,
        buyerName: _buyerName,
        buyerPhone: _buyerPhone,
        deliveryAddress: deliveryAddress,
        paymentMethod: _selectedPaymentMethod,
        cartItems: widget.cartItems,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                const Text("Order Confirmed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text("Thank you for supporting our local farmers. Your agricultural inputs are on their way!", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0
                    ),
                    child: const Text("Track Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: $e"), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    if (_addresses.length > 1)
                      TextButton(
                        onPressed: () => _showAddressSelector(),
                        child: const Text("Change", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_addresses.isEmpty)
                  GestureDetector(
                    onTap: _showAddAddressBottomSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_location_alt_outlined, size: 40, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text("Add Delivery Address", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                else
                  _buildSelectedAddressCard(),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _showAddAddressBottomSheet,
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                    label: const Text("Add New Address", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),

                const SizedBox(height: 24),
                const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                
                // Horizontal scrolling order summary
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Container(
                        width: 250,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                image: item['image'] != null && item['image'].toString().isNotEmpty
                                    ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: item['image'] == null || item['image'].toString().isEmpty
                                  ? const Icon(Icons.eco, color: AppColors.primaryLight)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text("${item['quantity']} ${item['unit']} • ₹${item['price']}", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 32),

                // Payment Method
                const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                _buildPaymentOption("Cash on Delivery", Icons.money_rounded, "Pay when you receive the order"),
                _buildPaymentOption("UPI / Net Banking", Icons.account_balance_wallet_rounded, "Google Pay, PhonePe, Paytm"),

                const SizedBox(height: 120), // Bottom padding
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Total to Pay", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text("₹${widget.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.4)
                      ),
                      onPressed: _isLoading ? null : placeOrder,
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text(
                              "PLACE ORDER",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    final addr = _addresses[_selectedAddressIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              shape: BoxShape.circle
            ),
            child: Icon(
              addr['label'] == 'Home' ? Icons.home_rounded : addr['label'] == 'Office' || addr['label'] == 'Work' ? Icons.business_rounded : Icons.location_on_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(addr['label'] ?? 'Address', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 8),
                    if (addr['isDefault'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text("Default", style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(addr['address'] ?? '', style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14)),
                if (addr['phone'] != null && addr['phone'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text("📞 ${addr['phone']}", style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
              const Text("Choose Delivery Address", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...List.generate(_addresses.length, (index) {
                final addr = _addresses[index];
                bool isSelected = _selectedAddressIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAddressIndex = index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          addr['label'] == 'Home' ? Icons.home_rounded : addr['label'] == 'Office' || addr['label'] == 'Work' ? Icons.business_rounded : Icons.location_on_rounded,
                          color: isSelected ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(addr['label'] ?? 'Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(addr['address'] ?? '', style: TextStyle(color: Colors.grey[600], height: 1.4, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String name, IconData icon, String subtitle) {
    bool isSelected = _selectedPaymentMethod == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider, width: isSelected ? 2 : 1),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 10)] : []
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background, shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            if (!isSelected) Icon(Icons.circle_outlined, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
