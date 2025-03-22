import 'package:floor/floor.dart';
import 'concert_item.dart';


/// **ConcertDao - Data Access Object**
///
/// This class provides methods to interact with the `ConcertItem` table,
/// including querying, inserting, updating, and deleting concert records.
@dao
abstract class ConcertDao {
  @Query('SELECT * FROM ConcertItem')
  Future<List<ConcertItem>> findAllConcerts();

  @insert
  Future<void> insertConcert(ConcertItem concert);

  @update
  Future<void> updateConcert(ConcertItem concert);

  @delete
  Future<void> deleteConcert(ConcertItem concert);
}
