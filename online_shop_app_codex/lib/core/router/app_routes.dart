class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const products = '/products';
  static const productDetails = '/products/:productId';
  static const categories = '/categories';
  static const cart = '/cart';
  static const profile = '/profile';
  static const search = '/search';
  static const searchName = 'productSearch';
  static const productDetailsName = 'productDetails';
  static const categoryProductsName = 'categoryProducts';
  static const categoryProducts = '/categories/:categoryId/products';
}
