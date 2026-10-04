class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const products = '/products';
  static const productDetails = '/products/:productId';
  static const categories = '/categories';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const checkoutName = 'checkout';
  static const profile = '/profile';
  static const orders = '/profile/orders';
  static const ordersName = 'orders';
  static const search = '/search';
  static const searchName = 'productSearch';
  static const productDetailsName = 'productDetails';
  static const categoryProductsName = 'categoryProducts';
  static const categoryProducts = '/categories/:categoryId/products';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verify = '/auth/verify';
  static const reset = '/auth/reset';
}
