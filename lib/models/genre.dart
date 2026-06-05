/// Data model representing a book genre.
///
/// Genres are derived dynamically from the book data rather than hardcoded,
/// allowing the data source to define available genres.
class Genre {
  final String name;

  const Genre(this.name);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Genre && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Genre($name)';
}
