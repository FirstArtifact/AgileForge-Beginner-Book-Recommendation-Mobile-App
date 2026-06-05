import 'package:flutter_test/flutter_test.dart';
import 'package:book_recommendation_app/models/book.dart';
import 'package:book_recommendation_app/models/genre.dart';
import 'package:book_recommendation_app/models/user_preferences.dart';

void main() {
  group('Book', () {
    test('fromJson creates a Book with all fields populated', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'genre': 'Fiction',
        'description': 'A story of the fabulously wealthy Jay Gatsby.',
        'coverUrl': 'https://example.com/cover.jpg',
        'publishYear': 1925,
      };

      final Book book = Book.fromJson(json);

      expect(book.id, '1');
      expect(book.title, 'The Great Gatsby');
      expect(book.author, 'F. Scott Fitzgerald');
      expect(book.genre, 'Fiction');
      expect(book.description, 'A story of the fabulously wealthy Jay Gatsby.');
      expect(book.coverUrl, 'https://example.com/cover.jpg');
      expect(book.publishYear, 1925);
    });

    test('fromJson handles nullable fields being null', () {
      final Map<String, dynamic> json = {
        'id': '2',
        'title': 'Unknown Book',
        'author': 'Anonymous',
        'genre': 'Mystery',
        'description': 'A mysterious tale.',
        'coverUrl': null,
        'publishYear': null,
      };

      final Book book = Book.fromJson(json);

      expect(book.coverUrl, isNull);
      expect(book.publishYear, isNull);
    });

    test('fromJson handles nullable fields being absent', () {
      final Map<String, dynamic> json = {
        'id': '3',
        'title': 'Minimal Book',
        'author': 'Author',
        'genre': 'Non-Fiction',
        'description': 'Short description.',
      };

      final Book book = Book.fromJson(json);

      expect(book.coverUrl, isNull);
      expect(book.publishYear, isNull);
    });

    test('toJson produces correct map with all fields', () {
      const Book book = Book(
        id: '1',
        title: 'Dune',
        author: 'Frank Herbert',
        genre: 'Science Fiction',
        description: 'A science fiction masterpiece.',
        coverUrl: 'https://example.com/dune.jpg',
        publishYear: 1965,
      );

      final Map<String, dynamic> json = book.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Dune');
      expect(json['author'], 'Frank Herbert');
      expect(json['genre'], 'Science Fiction');
      expect(json['description'], 'A science fiction masterpiece.');
      expect(json['coverUrl'], 'https://example.com/dune.jpg');
      expect(json['publishYear'], 1965);
    });

    test('toJson includes null values for nullable fields', () {
      const Book book = Book(
        id: '2',
        title: 'Test',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );

      final Map<String, dynamic> json = book.toJson();

      expect(json.containsKey('coverUrl'), isTrue);
      expect(json['coverUrl'], isNull);
      expect(json.containsKey('publishYear'), isTrue);
      expect(json['publishYear'], isNull);
    });

    test('serialization round-trip produces equal Book', () {
      const Book original = Book(
        id: 'abc-123',
        title: 'Round Trip Test',
        author: 'Test Author',
        genre: 'Fantasy',
        description: 'A book for testing round-trip serialization.',
        coverUrl: 'https://covers.example.com/image.png',
        publishYear: 2020,
      );

      final Book deserialized = Book.fromJson(original.toJson());

      expect(deserialized, equals(original));
    });

    test('serialization round-trip with null optional fields', () {
      const Book original = Book(
        id: 'xyz-789',
        title: 'Nullable Test',
        author: 'Null Author',
        genre: 'Non-Fiction',
        description: 'Testing null fields.',
      );

      final Book deserialized = Book.fromJson(original.toJson());

      expect(deserialized, equals(original));
    });

    test('equality operator works correctly', () {
      const Book book1 = Book(
        id: '1',
        title: 'Same Book',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );
      const Book book2 = Book(
        id: '1',
        title: 'Same Book',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );
      const Book book3 = Book(
        id: '2',
        title: 'Different Book',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );

      expect(book1, equals(book2));
      expect(book1, isNot(equals(book3)));
    });

    test('hashCode is consistent with equality', () {
      const Book book1 = Book(
        id: '1',
        title: 'Test',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );
      const Book book2 = Book(
        id: '1',
        title: 'Test',
        author: 'Author',
        genre: 'Fiction',
        description: 'Desc.',
      );

      expect(book1.hashCode, equals(book2.hashCode));
    });
  });

  group('Genre', () {
    test('creates a genre with a name', () {
      const Genre genre = Genre('Fiction');
      expect(genre.name, 'Fiction');
    });

    test('equality works correctly', () {
      const Genre genre1 = Genre('Fiction');
      const Genre genre2 = Genre('Fiction');
      const Genre genre3 = Genre('Mystery');

      expect(genre1, equals(genre2));
      expect(genre1, isNot(equals(genre3)));
    });

    test('hashCode is consistent with equality', () {
      const Genre genre1 = Genre('Science Fiction');
      const Genre genre2 = Genre('Science Fiction');

      expect(genre1.hashCode, equals(genre2.hashCode));
    });
  });

  group('UserPreferences', () {
    test('fromJson creates preferences with selected genre', () {
      final Map<String, dynamic> json = {'selectedGenre': 'Mystery'};

      final UserPreferences prefs = UserPreferences.fromJson(json);

      expect(prefs.selectedGenre, 'Mystery');
    });

    test('fromJson creates preferences with null genre', () {
      final Map<String, dynamic> json = {'selectedGenre': null};

      final UserPreferences prefs = UserPreferences.fromJson(json);

      expect(prefs.selectedGenre, isNull);
    });

    test('toJson produces correct map', () {
      const UserPreferences prefs = UserPreferences(selectedGenre: 'Fantasy');

      final Map<String, dynamic> json = prefs.toJson();

      expect(json['selectedGenre'], 'Fantasy');
    });

    test('toJson with null genre', () {
      const UserPreferences prefs = UserPreferences();

      final Map<String, dynamic> json = prefs.toJson();

      expect(json['selectedGenre'], isNull);
    });

    test('serialization round-trip with genre', () {
      const UserPreferences original =
          UserPreferences(selectedGenre: 'Non-Fiction');

      final UserPreferences deserialized =
          UserPreferences.fromJson(original.toJson());

      expect(deserialized, equals(original));
    });

    test('serialization round-trip with null genre', () {
      const UserPreferences original = UserPreferences();

      final UserPreferences deserialized =
          UserPreferences.fromJson(original.toJson());

      expect(deserialized, equals(original));
    });

    test('equality works correctly', () {
      const UserPreferences prefs1 = UserPreferences(selectedGenre: 'Fiction');
      const UserPreferences prefs2 = UserPreferences(selectedGenre: 'Fiction');
      const UserPreferences prefs3 = UserPreferences(selectedGenre: 'Mystery');

      expect(prefs1, equals(prefs2));
      expect(prefs1, isNot(equals(prefs3)));
    });
  });
}
