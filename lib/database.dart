import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'review_dao.dart';
import 'review_item.dart';
import 'concert_dao.dart';
import 'concert_item.dart';

part 'database.g.dart';

/// ** Application Database**
///
/// `AppDatabase` is the main Floor database class that manages the `ReviewItem` and `ConcertItem` tables.
@Database(version: 1, entities: [ReviewItem, ConcertItem])
abstract class AppDatabase extends FloorDatabase {
  ReviewDao get reviewDao;
  ConcertDao get concertDao;
}
