import 'package:floor/floor.dart';


/// Represents a single review submitted by a user.
///
/// Includes details like the username, title, review content, rating, and date.
@entity
class ReviewItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String username;
  final String title;
  final String review;
  final int rating;
  final String date;


  ReviewItem({
    this.id,
    required this.username,
    required this.title,
    required this.review,
    required this.rating,
    required this.date,

  });
}
