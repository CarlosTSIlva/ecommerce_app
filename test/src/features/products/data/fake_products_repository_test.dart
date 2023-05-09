import 'package:ecommerce_app/src/constants/test_products.dart';
import 'package:ecommerce_app/src/features/products/data/fake_products_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FakeProductsRepository makeProductsRepository() =>
      FakeProductsRepository(addDelay: false);
  group('FakeProductsRepository', () {
    test("getProductsList resturns global list", () {
      final productRepository = makeProductsRepository();
      expect(productRepository.getProductsList(), kTestProducts);
    });

    test("getProduct(1) returns frist item", () {
      final productRepository = makeProductsRepository();

      expect(
        productRepository.getProductById("1"),
        kTestProducts.first,
      );
    });

    test("getProduct(100) returns null", () {
      final productRepository = makeProductsRepository();

      expect(
        productRepository.getProductById("100"),
        null,
      );
    });
  });

  test("fetchProductList returns global list", () async {
    final productRepository = makeProductsRepository();

    expect(
      await productRepository.fetchProductsList(),
      kTestProducts,
    );
  });

  test("watchProductList returns global list", () async {
    final productRepository = makeProductsRepository();

    expect(
      productRepository.watchProductsList(),
      emits(kTestProducts),
    );
  });

  test('watchProduct(1) emit first item', () {
    final productRepository = makeProductsRepository();

    expect(
      productRepository.whatchProduct('1'),
      emits(kTestProducts.first),
    );
  });

  test('watchProduct(100) emits null', () {
    final productRepository = makeProductsRepository();

    expect(
      productRepository.whatchProduct('100'),
      emits(null),
    );
  });
}
