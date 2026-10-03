import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screens.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/categories/presentation/category_products_screen.dart';
import '../../features/products/presentation/product_search_screen.dart';
import '../../features/products/presentation/product_details_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import 'auth_guard.dart';
import 'app_navigation_shell.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.checkoutName,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(redirect: state.uri.queryParameters['redirect']),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) =>
            RegisterScreen(redirect: state.uri.queryParameters['redirect']),
      ),
      GoRoute(
        path: AppRoutes.verify,
        builder: (context, state) {
          final data = state.extra as Map<String, String?>?;
          return VerifyScreen(
            email: data?['email'] ?? state.uri.queryParameters['email'] ?? '',
            redirect: data?['redirect'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.reset,
        builder: (context, state) => const ResetScreen(),
      ),
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
                routes: [
                  GoRoute(
                    path: 'orders',
                    name: AppRoutes.ordersName,
                    builder: (context, state) => OrdersScreen(
                      createdOrderId: int.tryParse(
                        state.uri.queryParameters['createdOrderId'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      if ((state.matchedLocation == AppRoutes.checkout ||
              state.matchedLocation == AppRoutes.orders) &&
          auth.hasValue) {
        final redirect = requireAuthentication(auth.value!, state);
        if (redirect != null) return redirect;
      }
      final isAuthRoute = state.matchedLocation.startsWith('/auth/');
      if (auth.isLoading || !auth.hasValue) return null;
      if (auth.value!.isAuthenticated && isAuthRoute) {
        final target = state.uri.queryParameters['redirect'];
        return target != null &&
                target.startsWith('/') &&
                !target.startsWith('//') &&
                !target.startsWith('/auth/')
            ? target
            : AppRoutes.home;
      }
      return null;
    },
  );
});
