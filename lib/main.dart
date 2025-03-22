import 'package:flutter/material.dart';
import 'see_all_page.dart';
import 'database.dart';
import 'review_page.dart';
import 'dart:async';
import 'package:floor/floor.dart';
import 'dart:math';
import 'new_concert_page.dart';
import 'concert_item.dart';
import 'review_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database =
      await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database: database));
}


/// MyApp is the root widget of the application. It initializes the app with a given database.
///
/// It sets up the MaterialApp with routing, theme, and passes the database to the home page.
class MyApp extends StatelessWidget {
  final AppDatabase database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZHOUSHEN 9.29HZ WORLD TOUR CONCERT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: MyHomePage(database: database),
    );
  }
}

/// MyHomePage is the main home page of the app displaying concert info and latest reviews.
///
/// This stateful widget loads concert and review data and displays them in a structured UI.
/// It also supports refreshing welcome image, navigating to review and concert pages.
class MyHomePage extends StatefulWidget {
  final AppDatabase database;

  const MyHomePage({super.key, required this.database});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


/// State class for MyHomePage. Handles logic and UI updates.
///
/// Responsible for loading concert and review data, refreshing UI elements,
/// and handling user interactions such as navigating to other pages.
class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _searchController = TextEditingController();
  int _currentImageIndex = 0;
  bool _isLiked = false;
  List<ConcertItem> _concerts = [];
  ReviewItem? _latestReview;
  int _totalReviews = 0;
  double _averageRating = 0.0;

  final List<String> _welcomeImages = [
    'images/welcome1.jpg',
    'images/welcome2.jpg',
    'images/welcome3.jpg',
    'images/welcome4.jpg',
    'images/welcome5.jpg',
    'images/welcome6.jpg',
    // Add more image paths as needed
  ];

  @override
  void initState() {
    super.initState();
    _loadLatestReview();
    // Set initial random image when page first loads
    _selectRandomImage();
    _loadConcerts();
  }

  Future<void> _loadConcerts() async {
    final concertDao = widget.database.concertDao;
    final concerts = await concertDao.findAllConcerts();
    setState(() {
      _concerts = concerts;
    });
  }

 
  void _selectRandomImage() {
    final random = Random();
    setState(() {
      _currentImageIndex = random.nextInt(_welcomeImages.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(35), // ✅ 这里可以改高度，默认是 56
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "EN / CN",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _selectRandomImage,
            ),
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("How to use"),
                    content:
                        Text("Click the refresh button to change the image."),
                    actions: [
                      TextButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to 9.29Hz ZHOU SHEN World Concert Tour !",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Stack(
                children: [
                  SizedBox(
                    //SizedBox(
                    width: 350, // 🔥 固定宽度

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        _welcomeImages[_currentImageIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Reviews (${_totalReviews})",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SeeAllPage(database: widget.database)),
                      );
                    },
                    child: Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 204, 161, 106),
                      ),
                    ),
                  ),
                ],
              ),
              if (_totalReviews > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      SizedBox(width: 4),
                      Text(
                        "${_averageRating.toStringAsFixed(1)}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              if (_latestReview != null)
                Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _latestReview!.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              _latestReview!.date,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < _latestReview!.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _truncateReview(_latestReview?.review ?? ""),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Concerts",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NewConcertPage(database: widget.database),
                        ),
                      );
                      // Refresh concert list when returning from NewConcertPage
                      if (result == true) {
                        _loadConcerts();
                      }
                    },
                    child: Text("+ New Concert",
                        style: TextStyle(
                            color: Color.fromARGB(255, 204, 161, 106),
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200, 
                child: _concerts.isEmpty
                    ? Center(child: Text("No upcoming concerts."))
                    : ListView.separated(
                        itemCount: _concerts.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          final concert = _concerts[index];
                          return ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: "${concert.date}  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  // TextSpan(text: "Zhoushen "),
                                  TextSpan(
                                      text: concert.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            subtitle: Text("Location: ${concert.location}",
                                style: TextStyle(color: Colors.black54)),
                            onTap: () async {
                              // Navigate to NewConcertPage for editing
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewConcertPage(
                                    database: widget.database,
                                    concertToEdit: concert,
                                  ),
                                ),
                              );
                              // Refresh concerts list when returning
                              if (result == true) {
                                _loadConcerts();
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadLatestReview() async {
    final reviewDao = widget.database.reviewDao;
    final reviews = await reviewDao.findAllReviews();

    if (reviews.isNotEmpty) {
      
      reviews.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _latestReview = reviews.first; 
        _totalReviews = reviews.length;
        _averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) /
            _totalReviews;
      });
    }
  }

  String _truncateReview(String review) {
    List<String> words = review.split(" ");
    if (words.length > 40) {
      return words.sublist(0, 40).join(" ") + " ...";
      ;
    }
    return review;
  }

  Widget _buildReviewCard(ReviewItem review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: Color.fromARGB(255, 240, 245, 245), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text(
              review.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 4),

            Text(
              "by ${review.username}",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 8),

            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
            ),
            SizedBox(height: 4),

            Text(
              _truncateReview(review.review),
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
