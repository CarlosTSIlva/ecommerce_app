import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/authentication/domain/app_user.dart';
import 'package:ecommerce_app/src/features/cart/application/cart_service.dart';
import 'package:ecommerce_app/src/features/cart/data/local/local_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/remote/remote_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/domain/cart.dart';
import 'package:ecommerce_app/src/features/cart/domain/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const Cart());
  });

  late MockAuthRepository mockAuthRepository;
  late MockLocalCartRepository mockLocalCartRepository;
  late MockRemoteCartRepository mockRemoteCartRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockLocalCartRepository = MockLocalCartRepository();
    mockRemoteCartRepository = MockRemoteCartRepository();
  });

  CartService makeCartService() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        localCartRepositoryProvider.overrideWithValue(mockLocalCartRepository),
        remoteCartRepositoryProvider
            .overrideWithValue(mockRemoteCartRepository),
      ],
    );

    addTearDown(container.dispose);

    return container.read(cartServiseProvider);
  }

  group("setItem", () {
    test("null user, writes item to local cart", () async {
      const expected = Cart({'123': 1});

      when(() => mockAuthRepository.currentUser).thenReturn(null);
      when(mockLocalCartRepository.fetchCart).thenAnswer(
        (_) => Future.value(
          const Cart(),
        ),
      );
      when(() => mockLocalCartRepository.setCart(expected)).thenAnswer(
        (_) => Future.value(),
      );

      final cartService = makeCartService();

      await cartService.setItem(
        const Item(
          productId: "123",
          quantity: 1,
        ),
      );

      verify(() => mockLocalCartRepository.setCart(expected)).called(1);

      verifyNever(() => mockRemoteCartRepository.setCart(any(), any()));
    });

    test("non-null user, writes item to remote cart", () async {
      const testUser = AppUser(uid: 'uid');
      const expected = Cart({'123': 1});

      when(() => mockAuthRepository.currentUser).thenReturn(testUser);
      when(() => mockRemoteCartRepository.fetchCart(testUser.uid)).thenAnswer(
        (_) => Future.value(
          const Cart(),
        ),
      );
      when(() => mockRemoteCartRepository.setCart(testUser.uid, expected))
          .thenAnswer(
        (_) => Future.value(),
      );

      final cartService = makeCartService();

      await cartService.setItem(
        const Item(
          productId: "123",
          quantity: 1,
        ),
      );

      verify(() => mockRemoteCartRepository.setCart(testUser.uid, expected))
          .called(1);

      verifyNever(() => mockLocalCartRepository.setCart(any()));
    });
  });
}
