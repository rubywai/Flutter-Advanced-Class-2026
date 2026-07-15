import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/products/presentation/product_details_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'productDetails',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailsScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
