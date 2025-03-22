import 'package:flutter/material.dart';
import 'database.dart';
import 'review_dao.dart';
import 'review_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


/// A page where users can write and submit a review for a concert or event.
/// Review includes title, rating, content, and user name.
/// Submissions are stored in both database and secure local storage.
class WriteReviewPage extends StatefulWidget {
  final AppDatabase database;

  WriteReviewPage({required this.database});

  @override
  _WriteReviewPageState createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  late ReviewDao _reviewDao;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reviewDao = widget.database.reviewDao;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _saveReviewToPreferences(ReviewItem review) async {
    final storage = FlutterSecureStorage();

    await storage.write(key: 'last_review_username', value: review.username);
    await storage.write(key: 'last_review_title', value: review.title);
    await storage.write(key: 'last_review_content', value: review.review);

    await storage.write(key: 'last_review_rating', value: review.rating.toString());
  }

  Future<void> _submitReview() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_usernameController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _reviewController.text.isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select a rating!")),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final review = ReviewItem(
      username: _usernameController.text,
      title: _titleController.text,
      review: _reviewController.text,
      rating: _rating,
      date: DateTime.now().toIso8601String().split("T")[0],
    );

    await _reviewDao.insertReview(review);
    await _saveReviewToPreferences(review);

    setState(() {
      _isSubmitting = false;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Write a Review")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Rating"),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Your Name"),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Review Title"),
            ),
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(labelText: "Review"),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 204, 161, 106),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
