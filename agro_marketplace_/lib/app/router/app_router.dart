import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/enums/auth_status.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/buyer_shopping/presentation/screens/buyer_home_screen.dart';
import '../../features/buyer_shopping/presentation/screens/buyer_main_screen.dart';
import '../../features/buyer_shopping/presentation/screens/cart_screen.dart';
import '../../features/buyer_shopping/presentation/screens/checkout_screen.dart';
import '../../features/buyer_shopping/presentation/screens/product_detail_screen.dart';
import '../../features/buyer_profile/presentation/screens/buyer_profile_screen.dart';
import '../../features/profile_management/presentation/screens/edit_profile_screen.dart';
import '../../features/buyer_shopping/presentation/screens/buyer_search_screen.dart';
import '../../features/buyer_shopping/presentation/screens/buyer_orders_screen.dart';
import '../../features/buyer_shopping/presentation/screens/buyer_order_detail_screen.dart';
import '../../features/seller_dashboard/presentation/screens/seller_dashboard_screen.dart';
import '../../features/seller_inventory/presentation/screens/add_edit_product_screen.dart';
import '../../features/seller_inventory/presentation/screens/seller_products_screen.dart';
import '../../features/seller_navigation/presentation/screens/seller_main_screen.dart';
import '../../features/seller_onboarding/presentation/screens/seller_onboarding_screen.dart';
import '../../features/seller_orders/presentation/screens/seller_orders_screen.dart';
import '../../features/seller_orders/presentation/screens/seller_order_detail_screen.dart';
import '../../features/seller_profile/presentation/screens/seller_profile_screen.dart';
import '../../features/seller_profile/presentation/screens/business_settings_screen.dart';
import '../../features/seller_profile/presentation/screens/seller_settings_screen.dart';
import '../../features/seller_profile/presentation/screens/seller_help_screen.dart';
import 'route_names.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  final authStatus = ref.watch(authStatusProvider);
  final appUser = ref.watch(appUserProvider).value;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';
      final isForgotPassword = state.matchedLocation == '/forgot-password';

      final isAuthRoute = isLogin || isRegister || isForgotPassword;

      switch (authStatus) {
        case AuthStatus.initial:
        case AuthStatus.authenticating:
          if (authStatus == AuthStatus.initial && !isSplash) return '/splash';
          return null;
        case AuthStatus.unauthenticated:
          if (!isAuthRoute) return '/login';
          return null;
        case AuthStatus.emailUnverified:
          if (state.matchedLocation != '/email-verification') return '/email-verification';
          return null;
        case AuthStatus.authenticated:
          // If appUser profile is not yet loaded, stay on splash screen so we don't route to the wrong role
          if (appUser == null) {
            return isSplash ? null : '/splash';
          }

          final isSeller = appUser.role == 'seller';
          final isBuyer = appUser.role == 'buyer';

          // When coming from splash, auth routes, or email verification, redirect to home screen
          if (isSplash || isAuthRoute || state.matchedLocation == '/email-verification') {
            return isSeller ? '/seller/dashboard' : '/buyer/home';
          }

          final isBuyerRoute = state.matchedLocation.startsWith('/buyer');
          final isSellerRoute = state.matchedLocation.startsWith('/seller');

          // Strict role protection:
          // A seller should NEVER see buyer screens
          if (isSeller && isBuyerRoute) {
            return '/seller/dashboard';
          }

          // A buyer should NEVER see seller screens
          if (isBuyer && isSellerRoute) {
            return '/buyer/home';
          }

          return null;
      }
    },
    routes: [
      // === Auth routes ===
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/email-verification',
        name: RouteNames.emailVerification,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // === Buyer Navigation Shell ===
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BuyerMainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/home',
                name: RouteNames.buyerHome,
                builder: (context, state) => const BuyerHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: RouteNames.buyerSearch,
                    builder: (context, state) => const BuyerSearchScreen(),
                  ),
                  GoRoute(
                    path: 'product/:id',
                    name: RouteNames.buyerProductDetail,
                    builder: (context, state) => ProductDetailScreen(
                      productId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/cart',
                name: RouteNames.buyerCart,
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    name: RouteNames.buyerCheckout,
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/orders',
                name: RouteNames.buyerOrders,
                builder: (context, state) => const BuyerOrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.buyerOrderDetail,
                    builder: (context, state) => BuyerOrderDetailScreen(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/buyer/profile',
                name: RouteNames.buyerProfile,
                builder: (context, state) => const BuyerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // === Seller Navigation Shell ===
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SellerMainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/dashboard',
                name: RouteNames.sellerDashboard,
                builder: (context, state) => const SellerDashboardScreen(),
              ),
            ],
          ),
          // Branch 1: Products
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/products',
                name: RouteNames.sellerProducts,
                builder: (context, state) => const SellerProductsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: RouteNames.sellerAddProduct,
                    builder: (context, state) => const AddEditProductScreen(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    name: RouteNames.sellerEditProduct,
                    builder: (context, state) => AddEditProductScreen(
                      productId: state.pathParameters['id'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/orders',
                name: RouteNames.sellerOrders,
                builder: (context, state) => const SellerOrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.sellerOrderDetail,
                    builder: (context, state) => SellerOrderDetailScreen(
                      orderId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/seller/profile',
                name: RouteNames.sellerProfile,
                builder: (context, state) => const SellerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // === Other Seller Routes (Modals, Details, Onboarding) ===
      GoRoute(
        path: '/seller/onboarding',
        name: RouteNames.sellerOnboarding,
        builder: (context, state) => const SellerOnboardingScreen(),
      ),
      GoRoute(
        path: '/seller/inventory',
        name: RouteNames.sellerInventory,
        builder: (context, state) => const SellerProductsScreen(),
      ),
      GoRoute(
        path: '/seller/settings',
        name: RouteNames.sellerSettings,
        builder: (context, state) => const SellerSettingsScreen(),
      ),
      GoRoute(
        path: '/seller/business-profile',
        name: RouteNames.sellerBusinessProfile,
        builder: (context, state) => const BusinessSettingsScreen(),
      ),
      GoRoute(
        path: '/seller/help',
        name: RouteNames.sellerHelp,
        builder: (context, state) => const SellerHelpScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
