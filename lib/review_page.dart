import 'package:flutter/material.dart';
import 'database.dart';
import 'review_dao.dart';
import 'review_item.dart';
import 'write_review_page.dart';

/// A page that displays all reviews in list or grid format,
/// depending on screen size (responsive for mobile, tablet, desktop).
class ReviewPage extends StatefulWidget {
  final AppDatabase database;

  ReviewPage({required this.database});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late ReviewDao _reviewDao;
  List<ReviewItem> _reviews = [];

  @override
  void initState() {
    super.initState();
    _reviewDao = widget.database.reviewDao;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _reviewDao.findAllReviews();
    setState(() {
      _reviews = reviews;
    });
  }

  Future<void> _deleteReview(ReviewItem review) async {
    await _reviewDao.deleteReview(review);
    _loadReviews();
  }

   @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print("Screen Width: $screenWidth"); 
    bool isTabletOrDesktop = screenWidth > 600; 

    return Scaffold(
      appBar: AppBar(title: Text("Reviews")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isTabletOrDesktop
                  ? _buildGridLayout(screenWidth) 
                  : _buildListLayout(), 
            ),

            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            WriteReviewPage(database: widget.database)),
                  );
                  _loadReviews();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC89C66), 
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("Write a Review",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildListLayout() {
    return _reviews.isEmpty
        ? Center(child: Text("No reviews yet."))
        : ListView.builder(
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(_reviews[index], double.infinity);
            },
          );
  }

 
  Widget _buildGridLayout(double screenWidth) {
    return _reviews.isEmpty
        ? Center(child: Text("No reviews yet."))
        : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 1200 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5, 
            ),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(_reviews[index],
                  screenWidth / (screenWidth > 1200 ? 3 : 2) - 32);
            },
          );
  }

  
  Widget _buildReviewCard(ReviewItem review, double width) {
    return Card(
      elevation: 3,
      child: Container(
        width: width, 
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100, 
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.username,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(review.date,
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),

            
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < review.rating ? Colors.orange : Colors.grey,
                  size: 18,
                ),
              ),
            ),

            
            const SizedBox(height: 4),
            Text(review.review, maxLines: 2, overflow: TextOverflow.ellipsis),

            
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteReview(review),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
