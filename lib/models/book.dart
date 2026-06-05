/// Data model representing a book in the recommendation app.
///
/// This model uses strict Dart null safety with explicit type definitions.
/// The [coverUrl] and [publishYear] fields are nullable since not all books
/// have cover images or known publish years.
///
/// Note: `isFavorite` is a computed property derived from the favorites state,
/// not stored on the model itself. This keeps the model pure and avoids stale state.
class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String? coverUrl;
  final int? publishYear;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    this.coverUrl,
    this.publishYear,
  });

  /// Creates a [Book] instance from a JSON map.
  ///
  /// Expects keys: 'id', 'title', 'author', 'genre', 'description'.
  /// Optional keys: 'coverUrl', 'publishYear'.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      genre: json['genre'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String?,
      publishYear: json['publishYear'] as int?,
    );
  }

  /// Converts this [Book] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'coverUrl': coverUrl,
      'publishYear': publishYear,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.genre == genre &&
        other.description == description &&
        other.coverUrl == coverUrl &&
        other.publishYear == publishYear;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      author,
      genre,
      description,
      coverUrl,
      publishYear,
    );
  }

  @override
  String toString() {
    return 'Book(id: $id, title: $title, author: $author, genre: $genre)';
  }
}
