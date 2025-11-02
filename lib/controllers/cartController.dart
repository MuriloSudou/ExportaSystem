import 'package:exportasystem/helper/databaseHelper.dart';
import 'package:exportasystem/models/productModel.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
class CartController extends GetxController {
  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  Future<int> addProductToCart(int productId) async {
    final db = await database;
    return await db.insert('cart', {'productId': productId});
  }

  Future<int> removeProductFromCart(int productId) async {
    final db = await database;
    return await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<List<Product>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT products.* FROM products
      JOIN cart ON products.id = cart.productId
    ''');

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }
}
