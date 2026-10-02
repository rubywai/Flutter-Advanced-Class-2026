import 'package:sqflite/sqflite.dart';

import '../../../products/data/models/product_detail.dart';
import '../models/cart_item.dart';

class CartService {
  Future<Database>? _opening;
  Future<void> _tail = Future<void>.value();

  Future<Database> _database() async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async => openDatabase(
    '${await getDatabasesPath()}/shop_cart.db',
    version: 2,
    onCreate: (db, version) => db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        variation_id INTEGER NOT NULL DEFAULT 0,
        options_json TEXT NOT NULL DEFAULT '{}',
        name TEXT NOT NULL, image_url TEXT NOT NULL, price TEXT NOT NULL,
        quantity INTEGER NOT NULL CHECK(quantity > 0),
        manage_stock INTEGER NOT NULL, stock_quantity INTEGER,
        stock_status TEXT NOT NULL, backorders_allowed INTEGER NOT NULL,
        UNIQUE(product_id, variation_id)
      )
    '''),
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('''
          CREATE TABLE cart_items_v2 (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id INTEGER NOT NULL,
            variation_id INTEGER NOT NULL DEFAULT 0,
            options_json TEXT NOT NULL DEFAULT '{}',
            name TEXT NOT NULL, image_url TEXT NOT NULL, price TEXT NOT NULL,
            quantity INTEGER NOT NULL CHECK(quantity > 0),
            manage_stock INTEGER NOT NULL, stock_quantity INTEGER,
            stock_status TEXT NOT NULL, backorders_allowed INTEGER NOT NULL,
            UNIQUE(product_id, variation_id)
          )
        ''');
        await db.execute('''
          INSERT INTO cart_items_v2 (
            product_id, variation_id, options_json, name, image_url, price,
            quantity, manage_stock, stock_quantity, stock_status, backorders_allowed
          ) SELECT product_id, 0, '{}', name, image_url, price, quantity,
            manage_stock, stock_quantity, stock_status, backorders_allowed
          FROM cart_items
        ''');
        await db.execute('DROP TABLE cart_items');
        await db.execute('ALTER TABLE cart_items_v2 RENAME TO cart_items');
      }
    },
  );

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  Future<List<CartItem>> _read(DatabaseExecutor db) async => List.unmodifiable(
    (await db.query('cart_items', orderBy: 'id')).map(CartItem.fromRow),
  );

  Future<List<CartItem>> load() =>
      _serial(() async => _read(await _database()));

  Future<List<CartItem>> add(
    ProductDetail product,
    int quantity, {
    ProductVariation? variation,
    Map<String, String> options = const {},
  }) => _serial(() async {
    if (product.type == 'variable') {
      if (variation == null || !product.variationIds.contains(variation.id)) {
        throw const CartException('Choose an available product option.');
      }
      final selected = {
        for (final entry in options.entries)
          entry.key.trim().toLowerCase(): entry.value.trim().toLowerCase(),
      };
      if (variation.attributes.length != selected.length ||
          !selected.entries.every(
            (entry) =>
                variation.attributes[entry.key]?.trim().toLowerCase() ==
                entry.value,
          )) {
        throw const CartException('Selected product option is unavailable.');
      }
    } else if (variation != null) {
      throw const CartException('Invalid product option.');
    }
    if (quantity < 1) {
      throw const CartException('Choose a positive quantity.');
    }
    final item = CartItem.fromProduct(
      product,
      quantity,
      variation: variation,
      options: options,
    );
    if (CartMoney.tryParse(item.price) == null) {
      throw const CartException('Price unavailable.');
    }
    if (!item.permits(quantity)) {
      throw const CartException('This option is out of stock.');
    }
    final db = await _database();
    return db.transaction((txn) async {
      final rows = await txn.query(
        'cart_items',
        where: 'product_id = ? AND variation_id = ?',
        whereArgs: [product.id, item.variationId],
      );
      final previous = rows.isEmpty ? 0 : rows.first['quantity'] as int;
      final updated = CartItem.fromProduct(
        product,
        previous + quantity,
        variation: variation,
        options: options,
      );
      if (!updated.permits(updated.quantity)) {
        throw const CartException(
          'Requested quantity exceeds available stock.',
        );
      }
      await txn.insert(
        'cart_items',
        updated.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return _read(txn);
    });
  });

  Future<List<CartItem>> setQuantity(int id, int variationId, int quantity) =>
      _serial(() async {
        final db = await _database();
        return db.transaction((txn) async {
          final rows = await txn.query(
            'cart_items',
            where: 'product_id = ? AND variation_id = ?',
            whereArgs: [id, variationId],
          );
          if (rows.isEmpty) {
            throw const CartException('This item is no longer in your cart.');
          }
          if (!CartItem.fromRow(rows.first).permits(quantity)) {
            throw const CartException(
              'Requested quantity exceeds available stock.',
            );
          }
          await txn.update(
            'cart_items',
            {'quantity': quantity},
            where: 'product_id = ? AND variation_id = ?',
            whereArgs: [id, variationId],
          );
          return _read(txn);
        });
      });

  Future<List<CartItem>> remove(int id, int variationId) => _serial(() async {
    final db = await _database();
    return db.transaction((txn) async {
      await txn.delete(
        'cart_items',
        where: 'product_id = ? AND variation_id = ?',
        whereArgs: [id, variationId],
      );
      return _read(txn);
    });
  });
}
