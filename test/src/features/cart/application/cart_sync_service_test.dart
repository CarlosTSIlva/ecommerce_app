import 'package:ecommerce_app/src/constants/test_products.dart';
import 'package:ecommerce_app/src/features/authentication/data/fake_auth_repository.dart';
import 'package:ecommerce_app/src/features/authentication/domain/app_user.dart';
import 'package:ecommerce_app/src/features/cart/application/cart_sync_service.dart';
import 'package:ecommerce_app/src/features/cart/data/local/local_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/data/remote/remote_cart_repository.dart';
import 'package:ecommerce_app/src/features/cart/domain/cart.dart';
import 'package:ecommerce_app/src/features/products/data/fake_products_repository.dart';
import 'package:ecommerce_app/src/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockRemoteCartRepository mockRemoteCartRepository;
  late MockLocalCartRepository mockLocalCartRepository;
  late MockProductsRepository mockProductsRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockRemoteCartRepository = MockRemoteCartRepository();
    mockLocalCartRepository = MockLocalCartRepository();
    mockProductsRepository = MockProductsRepository();
  });

  CartSyncService makeCartSyncService() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        remoteCartRepositoryProvider
            .overrideWithValue(mockRemoteCartRepository),
        localCartRepositoryProvider.overrideWithValue(mockLocalCartRepository),
        productsRepositoryProvider.overrideWithValue(mockProductsRepository),
      ],
    );
    addTearDown(container.dispose);
    return container.read(cartSyncServiceProvider);
  }

  group('cartSyncService', () {
    Future<void> runCartSyncTest({
      required Map<ProductID, int> localCartItems,
      required Map<ProductID, int> remoteCartItems,
      required Map<ProductID, int> expectedRemoteCartItems,
    }) async {
      const uuid = "123";
      when(mockAuthRepository.authStateChanges).thenAnswer(
        (invocation) => Stream.value(
          const AppUser(uid: uuid, email: "carlos@c.com"),
        ),
      );

      when(mockProductsRepository.fetchProductsList)
          .thenAnswer((invocation) => Future.value(kTestProducts));

      when(mockLocalCartRepository.fetchCart)
          .thenAnswer((invocation) => Future.value(Cart(localCartItems)));

      when(() => mockRemoteCartRepository.fetchCart(uuid))
          .thenAnswer((invocation) => Future.value(Cart(remoteCartItems)));

      when(() => mockRemoteCartRepository.setCart(
              uuid, Cart(expectedRemoteCartItems)))
          .thenAnswer((invocation) => Future.value());

      when(() => mockLocalCartRepository.setCart(const Cart()))
          .thenAnswer((invocation) => Future.value());
      makeCartSyncService();
      await Future.delayed(const Duration());
      verify(
        () => mockRemoteCartRepository.setCart(
          uuid,
          Cart(expectedRemoteCartItems),
        ),
      ).called(1);

      verify(() => mockLocalCartRepository.setCart(const Cart())).called(1);
    }

    test('local quantity <= available quantity', () async {
      await runCartSyncTest(
        localCartItems: {'1': 1},
        remoteCartItems: {},
        expectedRemoteCartItems: {'1': 1},
      );
    });

    test('local quantity > available quantity', () async {
      await runCartSyncTest(
        localCartItems: {'1': 15},
        remoteCartItems: {},
        expectedRemoteCartItems: {'1': 5},
      );
    });

    test('local + remote quantity <= available quantity', () async {
      await runCartSyncTest(
        localCartItems: {'1': 1},
        remoteCartItems: {'1': 1},
        expectedRemoteCartItems: {'1': 2},
      );
    });

    test('local + remote quantity > available quantity', () async {
      await runCartSyncTest(
        localCartItems: {'1': 3},
        remoteCartItems: {'1': 3},
        expectedRemoteCartItems: {'1': 5},
      );
    });

    test('multiple items', () async {
      await runCartSyncTest(
        localCartItems: {'1': 3, '2': 1, '3': 2},
        remoteCartItems: {'1': 3},
        expectedRemoteCartItems: {'1': 5, '2': 1, '3': 2},
      );
    });
  });
}
