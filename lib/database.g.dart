// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ReviewDao? _reviewDaoInstance;

  ConcertDao? _concertDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ReviewItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL, `title` TEXT NOT NULL, `review` TEXT NOT NULL, `rating` INTEGER NOT NULL, `date` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ConcertItem` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `location` TEXT NOT NULL, `date` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ReviewDao get reviewDao {
    return _reviewDaoInstance ??= _$ReviewDao(database, changeListener);
  }

  @override
  ConcertDao get concertDao {
    return _concertDaoInstance ??= _$ConcertDao(database, changeListener);
  }
}

class _$ReviewDao extends ReviewDao {
  _$ReviewDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _reviewItemInsertionAdapter = InsertionAdapter(
            database,
            'ReviewItem',
            (ReviewItem item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'title': item.title,
                  'review': item.review,
                  'rating': item.rating,
                  'date': item.date
                }),
        _reviewItemDeletionAdapter = DeletionAdapter(
            database,
            'ReviewItem',
            ['id'],
            (ReviewItem item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'title': item.title,
                  'review': item.review,
                  'rating': item.rating,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ReviewItem> _reviewItemInsertionAdapter;

  final DeletionAdapter<ReviewItem> _reviewItemDeletionAdapter;

  @override
  Future<List<ReviewItem>> findAllReviews() async {
    return _queryAdapter.queryList('SELECT * FROM ReviewItem ORDER BY id DESC',
        mapper: (Map<String, Object?> row) => ReviewItem(
            id: row['id'] as int?,
            username: row['username'] as String,
            title: row['title'] as String,
            review: row['review'] as String,
            rating: row['rating'] as int,
            date: row['date'] as String));
  }

  @override
  Future<void> insertReview(ReviewItem review) async {
    await _reviewItemInsertionAdapter.insert(review, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteReview(ReviewItem review) async {
    await _reviewItemDeletionAdapter.delete(review);
  }
}

class _$ConcertDao extends ConcertDao {
  _$ConcertDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _concertItemInsertionAdapter = InsertionAdapter(
            database,
            'ConcertItem',
            (ConcertItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'location': item.location,
                  'date': item.date
                }),
        _concertItemUpdateAdapter = UpdateAdapter(
            database,
            'ConcertItem',
            ['id'],
            (ConcertItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'location': item.location,
                  'date': item.date
                }),
        _concertItemDeletionAdapter = DeletionAdapter(
            database,
            'ConcertItem',
            ['id'],
            (ConcertItem item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'location': item.location,
                  'date': item.date
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ConcertItem> _concertItemInsertionAdapter;

  final UpdateAdapter<ConcertItem> _concertItemUpdateAdapter;

  final DeletionAdapter<ConcertItem> _concertItemDeletionAdapter;

  @override
  Future<List<ConcertItem>> findAllConcerts() async {
    return _queryAdapter.queryList('SELECT * FROM ConcertItem',
        mapper: (Map<String, Object?> row) => ConcertItem(
            id: row['id'] as int?,
            name: row['name'] as String,
            location: row['location'] as String,
            date: row['date'] as String));
  }

  @override
  Future<void> insertConcert(ConcertItem concert) async {
    await _concertItemInsertionAdapter.insert(
        concert, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateConcert(ConcertItem concert) async {
    await _concertItemUpdateAdapter.update(concert, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteConcert(ConcertItem concert) async {
    await _concertItemDeletionAdapter.delete(concert);
  }
}
