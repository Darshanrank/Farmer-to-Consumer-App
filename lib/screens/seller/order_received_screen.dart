import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';

class OrderReceivedScreen extends StatefulWidget {
  const OrderReceivedScreen({super.key});

  @override
  State<OrderReceivedScreen> createState() => _OrderReceivedScreenState();
}

class _OrderReceivedScreenState extends State<OrderReceivedScreen> with SingleTickerProviderStateMixin {
  String? sellerId = FirebaseAuth.instance.currentUser?.uid;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _showDeclineDialog(String orderId) async {
    TextEditingController reasonController = TextEditingController();
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Decline Order", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Why are you declining this order?", style: TextStyle(color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: "Reason",
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error, width: 2)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A reason is required to decline")));
                  return;
                }
                confirmed = true;
                Navigator.pop(context);
              },
              child: const Text("Decline", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      try {
        await FirebaseFirestore.instance.collection("orders").doc(orderId).update({
          "status": "declined",
          "cancelReason": reasonController.text.trim(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order declined"), backgroundColor: AppColors.error));
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to decline order: $e"), backgroundColor: AppColors.error));
        }
      }
    }
    return false;
  }

  void _updateOrderStatus(String orderId, String newStatus, {Map<String, dynamic>? orderData}) async {
    try {
      Map<String, dynamic> updateFields = {"status": newStatus.toLowerCase()};

      if (orderData != null) {
        if (orderData['buyerName'] != null && orderData['buyerName'].toString().trim().isNotEmpty) {
          updateFields['buyerName'] = orderData['buyerName'];
        }
        if (orderData['buyerPhone'] != null && orderData['buyerPhone'].toString().trim().isNotEmpty) {
          updateFields['buyerPhone'] = orderData['buyerPhone'];
        }
      }

      await FirebaseFirestore.instance.collection("orders").doc(orderId).update(updateFields);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order marked as $newStatus"), backgroundColor: AppColors.success));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update status: $e"), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Premium Header with Tabs
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)),
                              const SizedBox(height: 4),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: sellerId).where('status', isEqualTo: 'pending').snapshots(),
                                builder: (context, snap) {
                                  int count = snap.hasData ? snap.data!.docs.length : 0;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                                    child: Text(count > 0 ? '$count pending order${count != 1 ? 's' : ''}' : 'All caught up!', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      padding: const EdgeInsets.all(4),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "Pending"),
                        Tab(text: "Delivered"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Order List
          Expanded(
            child: sellerId == null
                ? const Center(child: Text("User not authenticated"))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList("Pending", "Delivered"),
                      _buildOrderList("Delivered", null),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(String currentStatus, String? nextStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("orders").where("sellerId", isEqualTo: sellerId).where("status", isEqualTo: currentStatus.toLowerCase()).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.inbox_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                Text("No $currentStatus Orders", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text("Orders with status '$currentStatus' will appear here.", style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          );
        }

        var orders = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var doc = orders[index];
            var order = doc.data() as Map<String, dynamic>;
            
            Widget orderCard = _buildOrderCard(doc.id, order);

            bool isPending = currentStatus.toLowerCase() == "pending";

            if (nextStatus != null || isPending) {
              return Dismissible(
                key: Key(doc.id),
                direction: isPending ? DismissDirection.horizontal : DismissDirection.endToStart,
                background: isPending ? Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text("DECLINE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                    ],
                  ),
                ) : Container(),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("DELIVERED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd && isPending) {
                    return await _showDeclineDialog(doc.id);
                  }
                  if (direction == DismissDirection.endToStart && nextStatus != null) {
                    _updateOrderStatus(doc.id, nextStatus, orderData: order);
                  }
                  return false;
                },
                child: orderCard,
              );
            }
            return orderCard;
          },
        );
      },
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> order) {
    final bool hasBuyerName = order['buyerName'] != null && order['buyerName'].toString().trim().isNotEmpty;
    final bool hasBuyerPhone = order['buyerPhone'] != null && order['buyerPhone'].toString().trim().isNotEmpty;

    String buyerName = hasBuyerName ? order['buyerName'] : "Buyer";
    String buyerPhone = hasBuyerPhone ? order['buyerPhone'] : "";

    if (!hasBuyerPhone && order['deliveryAddress'] != null) {
      String address = order['deliveryAddress'].toString();
      List<String> lines = address.split('\n');
      if (lines.length > 1) {
        String possiblePhone = lines.last.trim();
        if (possiblePhone.startsWith('+') || RegExp(r'^[\d\s\-]{7,}').hasMatch(possiblePhone)) {
          buyerPhone = possiblePhone;
        }
      }
    }

    if (buyerPhone.isEmpty) buyerPhone = "N/A";

    return _buildOrderCardContent(orderId, order, buyerName, buyerPhone);
  }

  Widget _buildOrderCardContent(
    String orderId,
    Map<String, dynamic> order,
    String buyerName,
    String buyerMobile,
  ) {
    String orderDate = order['orderDate'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format(order['orderDate'].toDate()) : "Unknown time";
    bool isDelivered = order['status']?.toString().toLowerCase() == 'delivered';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Top Section (Buyer Info & Actions)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Text(buyerName.isNotEmpty ? buyerName[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(buyerName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(buyerMobile, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(orderDate, style: const TextStyle(color: AppColors.textHint, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.phone_rounded, color: Colors.blue, size: 20),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Calling $buyerMobile..."))),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary, size: 20),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Opening chat with $buyerName..."))),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          // Delivery Details Section
          if (order['deliveryAddress'] != null && order['deliveryAddress'].toString().isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on_rounded, color: Colors.orange, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DELIVERY ADDRESS", style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(order['deliveryAddress'] ?? "No Address", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
          ],
          
          // Bottom Section (Product Details)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: KisanImage(imageSource: order['imageUrl'] ?? order['image'] ?? '', width: 70, height: 70, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order['productName'] ?? "Unknown Product", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)),
                            child: Text("Qty: ${order['quantity']}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text((order['paymentMethod'] ?? "Cash").toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("₹${order['totalAmount']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                          if (!isDelivered)
                            Row(
                              children: [
                                const Text("SWIPE ", style: TextStyle(color: AppColors.textHint, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                Icon(Icons.swipe_rounded, size: 16, color: AppColors.textHint.withValues(alpha: 0.5)),
                              ],
                            ),
                          if (isDelivered)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                  SizedBox(width: 4),
                                  Text("DELIVERED", style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                ],
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
