import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/authentication/domain/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartSyncService {
  CartSyncService(
    this.ref,
  ) {
    _init();
  }
  final Ref ref;

  void _init() {
    ref.listen<AsyncValue<AppUser?>>(authStateChangesProvider,
        (previous, next) {
      final previusUser = previous?.value;
      final user = next.value;

      if (previusUser == null && user != null) {
        // user logged in
        // sync local cart to remote
      } else if (previusUser != null && user == null) {
        // user logged out
        // sync remote cart to local
      }
    });
  }
}

final cartSyncServiceProvider = Provider<CartSyncService>((ref) {
  return CartSyncService(ref);
});
