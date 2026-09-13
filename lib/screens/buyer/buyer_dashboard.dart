import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kisanbazaar/screens/buyer/profile_screen.dart';
import 'package:kisanbazaar/screens/buyer/cart_screen.dart';
import 'package:kisanbazaar/screens/buyer/search_screen.dart';
import 'package:kisanbazaar/screens/buyer/explore_screen.dart';
import 'package:kisanbazaar/utils/app_categories.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kisanbazaar/theme/app_colors.dart';
import 'package:kisanbazaar/screens/buyer/my_orders_screen.dart';
import 'package:kisanbazaar/widgets/modern_product_card.dart';
import 'package:kisanbazaar/widgets/modern_search_bar.dart';
import 'package:kisanbazaar/widgets/category_item.dart';
import 'package:kisanbazaar/widgets/promo_banner_carousel.dart';
import 'package:kisanbazaar/widgets/horizontal_product_list.dart';
import 'package:kisanbazaar/services/auth_service.dart';
import 'package:kisanbazaar/services/product_service.dart';
import 'package:kisanbazaar/services/cart_service.dart';
import 'package:kisanbazaar/models/product_model.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({super.key});

  @override
  State<BuyerDashboard> createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  bool _isInitialLoad = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
    _listenToCartCount();
    _initializeNotifications();
    _listenForNewProducts();
    _listenForOrderUpdates();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  void _listenForNewProducts() {
    FirebaseFirestore.instance.collection('products').snapshots().listen((snapshot) {
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data();
          if (data != null) {
            _showNotification(data['name'] ?? 'New Product', data['seller_name'] ?? 'A seller');
          }
        }
      }
    });
  }

  void _listenForOrderUpdates() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    FirebaseFirestore.instance
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialLoad) return;
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          var data = change.doc.data();
          if (data != null) {
            String status = data['status'] ?? '';
            _showNotification(data['productName'] ?? 'Order Update', 'Status: ${status.toUpperCase()}', title: 'Order Update');
          }
        }
      }
    });
  }

  Future<void> _showNotification(String titleOrProductName, String bodyOrSellerName, {String? title}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'order_updates_channel', 'Order Updates', importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond,
      title: title ?? 'New Product!',
      body: title != null ? bodyOrSellerName : '$bodyOrSellerName added $titleOrProductName.',
      notificationDetails: platformChannelSpecifics,
    );
  }

  void _listenToCartCount() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    _cartService.streamCartItems(userId).listen((items) {
      if (mounted) setState(() => _cartCount = items.length);
    });
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _selectedIndex = (prefs.getInt('buyer_selectedIndex') ?? 0).clamp(0, 4));
  }

  void _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('buyer_selectedIndex', index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BuyerDashboardHome(onTabChange: _onItemTapped),
          const ExploreScreen(),
          const CartScreen(),
          const MyOrdersScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.2),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary), label: "Home"),
            const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary), label: "Explore"),
            NavigationDestination(
              icon: Badge(
                label: Text('$_cartCount'),
                isLabelVisible: _cartCount > 0,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                label: Text('$_cartCount'),
                isLabelVisible: _cartCount > 0,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
              ),
              label: "Cart",
            ),
            const NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primary), label: "Orders"),
            const NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

class BuyerDashboardHome extends StatefulWidget {
  final Function(int)? onTabChange;
  const BuyerDashboardHome({super.key, this.onTabChange});

  @override
  State<BuyerDashboardHome> createState() => _BuyerDashboardHomeState();
}

class _BuyerDashboardHomeState extends State<BuyerDashboardHome> {
  String _selectedCategory = "All";
  final List<AppCategory> _categories = AppCategories.list;

  String _address = "Fetching address...";
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _authService.streamUserModel(userId).listen((user) {
        if (user != null && mounted) {
          setState(() {
            _address = user.address ?? (user.addresses.isNotEmpty ? user.addresses.first.address : "Add your address in profile");
          });
        }
      });
    }
  }

  void addToCart(ProductModel product) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    await _cartService.addToCart(buyerId: userId, productData: product.toJson());
    Fluttertoast.showToast(msg: "${product.name} added to cart!", backgroundColor: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar
        SliverAppBar(
          pinned: true,
          expandedHeight: 100,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text("Delivery in 24 hours", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 20),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Flexible(child: Text(_address, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onTabChange?.call(4),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2)),
                      child: const CircleAvatar(backgroundColor: AppColors.lightGreenBg, child: Icon(Icons.person_outline_rounded, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Sticky Search Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchBarDelegate(),
        ),

        // Promo Banner Carousel
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: PromoBannerCarousel(),
          ),
        ),

        // Categories Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shop by Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                TextButton(onPressed: () {}, child: const Text("See All", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),

        // Categories List
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return CategoryItem(
                  title: cat.title,
                  emoji: cat.emoji,
                  isSelected: _selectedCategory == cat.title,
                  onTap: () => setState(() => _selectedCategory = cat.title),
                );
              },
            ),
          ),
        ),

        // Trending Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: HorizontalProductList(
              title: "🔥 Trending Near You",
              productStream: _productService.streamTrendingProducts(),
            ),
          ),
        ),

        // Deals of the Day Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: HorizontalProductList(
              title: "⚡ Deals of the Day",
              productStream: _productService.streamDealsOfTheDay(),
            ),
          ),
        ),

        // Products Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            child: Text("Bestsellers in $_selectedCategory", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),

        // Product Grid
        StreamBuilder<List<ProductModel>>(
          stream: _selectedCategory == "All" ? _productService.streamProducts() : _productService.streamProductsByCategory(_selectedCategory),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
            var products = snapshot.data!;

            if (products.isEmpty) {
              return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text("No products found in $_selectedCategory"))));
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    var product = products[index];
                    return ModernProductCard(data: product.toJson(), onAdd: () => addToCart(product), index: index);
                  },
                  childCount: products.length,
                ),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ModernSearchBar(
        readOnly: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 70;
  @override
  double get minExtent => 70;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
