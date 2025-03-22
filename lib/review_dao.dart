import 'package:floor/floor.dart';
import 'review_item.dart';

/// Data Access Object (DAO) for handling database operations related to reviews.
@dao
abstract class ReviewDao {
  @Query('SELECT * FROM ReviewItem ORDER BY id DESC')
  Future<List<ReviewItem>> findAllReviews();

  @insert
  Future<void> insertReview(ReviewItem review);

  @delete
  Future<void> deleteReview(ReviewItem review);
}
