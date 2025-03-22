import 'package:flutter/material.dart';
import 'database.dart';
import 'review_item.dart';
import 'write_review_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// Displays a full list of all reviews with ability to select, view, and delete.
/// Shows details in side panel on tablet/desktop, and in new page on mobile.
class ReviewCard extends StatelessWidget {
  final ReviewItem review;
  final VoidCallback onDelete;
  final VoidCallback onSelect;

  const ReviewCard({
    Key? key,
    required this.review,
    required this.onDelete,
    required this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Delete Review"),
              content: Text("Are you sure you want to delete this review?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    onDelete();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      onTap: onSelect,
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐⭐⭐ 评分
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 4),

              // 🔥 加粗标题
              Text(
                review.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 4),

              // 🔥 灰色 "by 用户名"
              Text(
                "by ${review.username}",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 8),

              // 📌 显示完整评论
              Text(review.review),
            ],
          ),
        ),
      ),
    );
  }
}

class SeeAllPage extends StatefulWidget {
  final AppDatabase database;

  SeeAllPage({required this.database});

  @override
  _SeeAllPageState createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  List<ReviewItem> _savedReviews = [];
  ReviewItem? _selectedReview;

  @override
  void initState() {
    super.initState();
    _loadReviewFromPreferences();
  }

  Future<void> _loadReviewFromPreferences() async {
    final storage = FlutterSecureStorage();
    final username = await storage.read(key: 'last_review_username');
    final title = await storage.read(key: 'last_review_title');
    final content = await storage.read(key: 'last_review_content');
    final ratingStr = await storage.read(key: 'last_review_rating'); 
    
    final int rating = int.tryParse(ratingStr ?? '0') ?? 0; // 🔥 这里是字符串


    if (username != null &&
        title != null &&
        content != null &&
        rating != null) {
      final review = ReviewItem(
        username: username,
        title: title,
        review: content,
        rating: rating,
        date: DateTime.now().toIso8601String().split("T")[0],
      );

      setState(() {
        _savedReviews.add(review);
      });
    }
  }

  Future<void> _deleteReview(ReviewItem review) async {
    await widget.database.reviewDao.deleteReview(review);
    setState(() {});
  }

  Future<void> _deleteSavedReview() async {
    final storage = FlutterSecureStorage();
    await storage.delete(key: 'last_review_username');
    await storage.delete(key: 'last_review_title');
    await storage.delete(key: 'last_review_content');
    await storage.delete(key: 'last_review_rating');

    setState(() {
      _savedReviews.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTabletOrDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Reviews"),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          WriteReviewPage(database: widget.database)),
                );
              },
              icon: Icon(Icons.add, size: 18),
              label: Text("Write a Comment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 204, 161, 106),
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: FutureBuilder<List<ReviewItem>>(
              future: widget.database.reviewDao.findAllReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final List<ReviewItem> allReviews = [
                  ..._savedReviews,
                  if (snapshot.hasData) ...snapshot.data!,
                ];

                if (allReviews.isEmpty) {
                  return Center(child: Text("No reviews yet."));
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: ListView.builder(
                      itemCount: allReviews.length,
                      itemBuilder: (context, index) {
                        return ReviewCard(
                          review: allReviews[index],
                          onDelete: () {
                            if (_savedReviews.contains(allReviews[index])) {
                              _deleteSavedReview();
                            } else {
                              _deleteReview(allReviews[index]);
                            }
                          },
                          onSelect: () {
                            setState(() {
                              if (isTabletOrDesktop) {
                                _selectedReview = allReviews[index];
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewDetailPage(
                                        review: allReviews[index]),
                                  ),
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (isTabletOrDesktop)
            Expanded(
              flex: 3,
              child: _selectedReview == null
                  ? Center(child: Text("Select a review"))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ReviewCard(
                        review: _selectedReview!,
                        onDelete: () {},
                        onSelect: () {},
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}


class ReviewDetailPage extends StatelessWidget {
  final ReviewItem review;
  const ReviewDetailPage({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Review Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(review.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text("by ${review.username}",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 16),
            Text(review.review, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
