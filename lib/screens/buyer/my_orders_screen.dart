import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/widgets/kisan_image.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final String? buyerId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (buyerId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text("Please login to view your orders.", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: Colors.white,
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').where('buyerId', isEqualTo: buyerId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(Icons.shopping_bag_rounded, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 24),
                  const Text("No Orders Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text("You haven't placed any orders.", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            );
          }

          var orders = snapshot.data!.docs.toList();
          orders.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            Timestamp? aTime = aData['createdAt'] as Timestamp?;
            Timestamp? bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var doc = orders[index];
              var orderData = doc.data() as Map<String, dynamic>;

              String orderDate = orderData['createdAt'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format((orderData['createdAt'] as Timestamp).toDate()) : "Unknown date";
              String status = (orderData['status'] ?? "pending").toString().toLowerCase();
              String reason = orderData['cancelReason'] ?? "";

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section: Order ID & Date
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order #${doc.id.substring(0, 8).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textSecondary, letterSpacing: 0.5)),
                          Text(orderDate, style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    
                    // Product Details
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: KisanImage(imageSource: orderData['imageUrl'] ?? orderData['image'] ?? '', width: 70, height: 70, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orderData['productName'] ?? "Unknown Product", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(8)),
                                      child: Text("Qty: ${orderData['quantity']}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900)),
                                    ),
                                    const SizedBox(width: 8),
                                    Text("₹${orderData['totalAmount'] ?? orderData['total'] ?? '0'}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tracking / Status Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ORDER TRACKING", style: TextStyle(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          _buildTrackingTimeline(status),
                          
                          if ((status == 'declined' || status == 'cancelled') && reason.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Cancellation Reason", style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w900)),
                                        const SizedBox(height: 4),
                                        Text(reason, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrackingTimeline(String status) {
    if (status == 'declined' || status == 'cancelled') {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
          ),
          const SizedBox(width: 12),
          const Text("Order Cancelled", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      );
    }

    int currentStep = 0;
    if (status == 'pending') currentStep = 1;
    if (status == 'packed' || status == 'processing') currentStep = 2;
    if (status == 'delivered') currentStep = 3;

    return Row(
      children: [
        _buildStep("Placed", currentStep >= 1, true),
        _buildLine(currentStep >= 2),
        _buildStep("Packed", currentStep >= 2, false),
        _buildLine(currentStep >= 3),
        _buildStep("Delivered", currentStep >= 3, false),
      ],
    );
  }

  Widget _buildStep(String label, bool isCompleted, bool isFirst) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
            border: isCompleted ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 3) : null,
          ),
          child: isCompleted ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isCompleted ? FontWeight.w900 : FontWeight.bold, color: isCompleted ? AppColors.textPrimary : AppColors.textHint)),
      ],
    );
  }

  Widget _buildLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16), // Offset to align with circles, not text
        color: isCompleted ? AppColors.primary : AppColors.divider,
      ),
    );
  }
}
