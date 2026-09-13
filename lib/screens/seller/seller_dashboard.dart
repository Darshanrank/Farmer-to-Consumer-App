import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kisanbazaar/screens/seller/profile_screen.dart';
import 'package:kisanbazaar/screens/seller/add_product_screen.dart';
import 'package:kisanbazaar/screens/seller/my_products_screen.dart';
import 'package:kisanbazaar/screens/seller/order_received_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int savedIndex = prefs.getInt('seller_selectedIndex') ?? 0;

    if (savedIndex > 4 || savedIndex < 0) {
      savedIndex = 0;
    }

    setState(() {
      _selectedIndex = savedIndex;
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seller_selectedIndex', index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _saveSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeScreen(),
      const MyProductsScreen(),
      const AddProductScreen(), 
      const OrderReceivedScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Seller Hub',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 0.5, color: Colors.white),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_rounded, size: 22, color: Colors.white),
              onPressed: () => _onItemTapped(4),
            ),
          ),
        ],
      ),
      body: screens[_selectedIndex == 2 ? 0 : _selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              elevation: 4,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_rounded), label: 'Products'),
              BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt_rounded), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: false,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            onTap: (index) {
              if (index == 2) return;
              _onItemTapped(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              String name = "Seller";
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                name = data?['fullName'] ?? "Seller";
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  ],
                ),
              );
            },
          ),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: uid).snapshots(),
                  builder: (context, snapshot) {
                    double totalEarnings = 0;
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        if (data['status'] == 'Delivered' || data['status'] == 'delivered') {
                          totalEarnings += (data['totalAmount'] ?? data['total'] ?? 0.0).toDouble();
                        }
                      }
                    }
                    return _buildStatCard(
                      title: "Total Earnings",
                      value: "₹${totalEarnings.toStringAsFixed(0)}",
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.success,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: uid).where('status', isEqualTo: 'pending').snapshots(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Pending Orders",
                      value: snapshot.hasData ? snapshot.data!.docs.length.toString() : "0",
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').where('sellerId', isEqualTo: uid).snapshots(),
            builder: (context, snapshot) {
              return _buildStatCard(
                title: "Active Products",
                value: snapshot.hasData ? snapshot.data!.docs.length.toString() : "0",
                icon: Icons.inventory_2_rounded,
                color: Colors.blue,
                isFullWidth: true,
              );
            },
          ),

          const SizedBox(height: 32),

          // Recent Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text('Recent Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              TextButton(
                onPressed: () => _onItemTapped(3),
                child: const Text("View All", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('orders').where('sellerId', isEqualTo: uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
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
              
              int itemCount = orders.length > 5 ? 5 : orders.length;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  bool isDelivered = order['status'].toString().toLowerCase() == 'delivered';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: AppColors.divider)
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: isDelivered ? AppColors.success.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.receipt_long_rounded, color: isDelivered ? AppColors.success : Colors.orange, size: 20),
                      ),
                      title: Text('Order #${order.id.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      subtitle: Text('${order['status'] ?? 'pending'}'.toUpperCase(), style: TextStyle(color: isDelivered ? AppColors.success : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                      trailing: Text('₹${order['totalAmount'] ?? order['total'] ?? '0'}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary)),
                    ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 80), 
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.list_alt_rounded, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          const Text("No pending orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text("When buyers purchase your products, they will appear here.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}
