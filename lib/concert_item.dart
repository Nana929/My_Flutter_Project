import 'package:floor/floor.dart';

/// ** Concert Data Model**
///
/// `ConcertItem` represents a concert entity stored in the database.
@entity
class ConcertItem {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String name;
  final String location;
  final String date;

  ConcertItem(
      {this.id,
      required this.name,
      required this.location,
      required this.date});

  // **📌 创建 `copyWith` 方法用于更新**
  ConcertItem copyWith({String? name, String? location, String? date}) {
    return ConcertItem(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      date: date ?? this.date,
    );
  }
}
