import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/local/local_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/remote/remote_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/domain/item.dart';
import 'package:ecommerce_app/src/features/cart/domain/mutable_cart.dart';
import 'package:ecommerce_app/src/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart.dart';

class CartService {
  final Ref ref;
  CartService({
    required this.ref,
  });

  Future<Cart> _fetchCart() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      return await ref.read(remoteCartRepositoryProvider).fetchCart(user.uid);
    } else {
      return await ref.read(localCartRepositoryProvider).fetchCart();
    }
  }

  Future<void> _setCart(Cart cart) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      await ref.read(remoteCartRepositoryProvider).setCart(user.uid, cart);
    } else {
      await ref.read(localCartRepositoryProvider).setCart(cart);
    }
  }

  Future<void> setItem(Item item) async {
    final cart = await _fetchCart();
    final updated = cart.setItem(item);
    await _setCart(updated);
  }

  Future<void> addItem(Item item) async {
    final cart = await _fetchCart();
    final updated = cart.addItem(item);
    await _setCart(updated);
  }

  Future<void> removeItemById(ProductID productID) async {
    final cart = await _fetchCart();
    final updated = cart.removeItemById(productID);
    await _setCart(updated);
  }
}

final cartServiseProvider = Provider<CartService>((ref) {
  return CartService(ref: ref);
});
