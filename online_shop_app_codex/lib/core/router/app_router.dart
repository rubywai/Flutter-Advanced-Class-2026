import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/categories/presentation/category_products_screen.dart';
import '../../features/products/presentation/product_search_screen.dart';
import '../../features/products/presentation/product_details_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import 'app_navigation_shell.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const ProductsScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: AppRoutes.searchName,
                    builder: (context, state) => const ProductSearchScreen(),
                  ),
                  GoRoute(
                    path: 'products/:productId',
                    name: AppRoutes.productDetailsName,
                    builder: (context, state) {
                      final productId = state.pathParameters['productId']!;
                      return ProductDetailsScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                name: 'categories',
                builder: (context, state) => const CategoriesScreen(),
                routes: [
                  GoRoute(
                    path: ':categoryId/products',
                    name: AppRoutes.categoryProductsName,
                    builder: (context, state) => CategoryProductsScreen(
                      categoryId:
                          int.tryParse(
                            state.pathParameters['categoryId'] ?? '',
                          ) ??
                          0,
                      categoryName: state.uri.queryParameters['name'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                name: 'cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
