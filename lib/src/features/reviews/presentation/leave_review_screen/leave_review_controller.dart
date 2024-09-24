import 'package:ecommerce_app/src/features/products/domain/product.dart';
import 'package:ecommerce_app/src/features/reviews/application/reviews_service.dart';
import 'package:ecommerce_app/src/features/reviews/domain/review.dart';
import 'package:ecommerce_app/src/utils/current_date_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LeaveReviewController extends StateNotifier<AsyncValue<void>> {
  LeaveReviewController({
    required this.reviewsService,
    required this.currentDateBuilder,
  }) : super(const AsyncData(null));

  final ReviewsService reviewsService;
  final DateTime Function() currentDateBuilder;

  Future<void> submitReview({
    Review? previewReview,
    required ProductID productID,
    required double rating,
    required String comment,
    required void Function() onSuccess,
  }) async {
    if (previewReview == null ||
        rating != previewReview.rating ||
        comment != previewReview.comment) {
      final review = Review(
        rating: rating,
        comment: comment,
        date: currentDateBuilder(),
      );
      state = const AsyncLoading();

      final newState = await AsyncValue.guard(() =>
          reviewsService.submitReview(productId: productID, review: review));

      if (mounted) {
        state = newState;
        if (state.hasError == false) {
          onSuccess();
        }
      }
    } else {
      onSuccess();
    }
  }
}

final leaveReviewControllerProvider =
    StateNotifierProvider.autoDispose<LeaveReviewController, AsyncValue<void>>(
        (ref) {
  return LeaveReviewController(
    reviewsService: ref.watch(reviewsServiceProvider),
    currentDateBuilder: ref.read(currentDateBuilderProvider),
  );
});
