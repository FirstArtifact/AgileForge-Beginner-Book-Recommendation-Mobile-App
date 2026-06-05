import 'package:book_recommendation_app/models/book.dart';
import 'package:book_recommendation_app/services/book_data_source.dart';
import 'package:book_recommendation_app/services/recommendation_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A simple in-memory data source for testing recommendations.
class TestDataSource implements BookDataSource {
  final List<Book> books;

  TestDataSource(this.books);

  @override
  Future<List<Book>> getAllBooks() async => books;

  @override
  Future<List<Book>> getBooksByGenre(String genre) async =>
      books.where((b) => b.genre == genre).toList();

  @override
  Future<List<Book>> searchBooks(String query) async => [];

  @override
  Future<Book?> getBookById(String id) async {
    try {
      return books.firstWhere((b) => b.id == id);
    } on StateError {
      return null;
    }
  }
}

void main() {
  late RecommendationService service;

  setUp(() {
    service = RecommendationService();
  });

  // Sample books used across tests
  final sampleBooks = [
    const Book(
      id: '1',
      title: 'Fiction Book A',
      author: 'Author A',
      genre: 'Fiction',
      description: 'A fiction book.',
    ),
    const Book(
      id: '2',
      title: 'Fiction Book B',
      author: 'Author B',
      genre: 'Fiction',
      description: 'Another fiction book.',
    ),
    const Book(
      id: '3',
      title: 'Fiction Book C',
      author: 'Author C',
      genre: 'Fiction',
      description: 'Yet another fiction book.',
    ),
    const Book(
      id: '4',
      title: 'Mystery Book A',
      author: 'Author D',
      genre: 'Mystery',
      description: 'A mystery book.',
    ),
    const Book(
      id: '5',
      title: 'Mystery Book B',
      author: 'Author E',
      genre: 'Mystery',
      description: 'Another mystery book.',
    ),
    const Book(
      id: '6',
      title: 'Sci-Fi Book A',
      author: 'Author F',
      genre: 'Science Fiction',
      description: 'A sci-fi book.',
    ),
    const Book(
      id: '7',
      title: 'Sci-Fi Book B',
      author: 'Author G',
      genre: 'Science Fiction',
      description: 'Another sci-fi book.',
    ),
    const Book(
      id: '8',
      title: 'Fantasy Book A',
      author: 'Author H',
      genre: 'Fantasy',
      description: 'A fantasy book.',
    ),
    const Book(
      id: '9',
      title: 'Fantasy Book B',
      author: 'Author I',
      genre: 'Fantasy',
      description: 'Another fantasy book.',
    ),
    const Book(
      id: '10',
      title: 'Non-Fiction Book A',
      author: 'Author J',
      genre: 'Non-Fiction',
      description: 'A non-fiction book.',
    ),
  ];

  group('RecommendationService', () {
    group('with favorites', () {
      test('returns books from the same genres as favorites', () async {
        // Favorite a Fiction book (id: 1)
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1'],
          dataSource: dataSource,
        );

        // All recommended books should be Fiction (same genre as favorite)
        for (final book in results) {
          expect(book.genre, equals('Fiction'));
        }
      });

      test('excludes favorited books from recommendations', () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '2'],
          dataSource: dataSource,
        );

        final resultIds = results.map((b) => b.id).toSet();
        expect(resultIds.contains('1'), isFalse);
        expect(resultIds.contains('2'), isFalse);
      });

      test('returns at most 5 recommendations', () async {
        // Create a larger catalog with many books in one genre
        final manyBooks = List.generate(
          20,
          (i) => Book(
            id: 'book-$i',
            title: 'Book $i',
            author: 'Author $i',
            genre: 'Fiction',
            description: 'Description $i',
          ),
        );
        final dataSource = TestDataSource(manyBooks);

        final results = await service.getRecommendations(
          favoriteBookIds: ['book-0'],
          dataSource: dataSource,
        );

        expect(results.length, lessThanOrEqualTo(5));
      });

      test('sorts by genre frequency descending', () async {
        // Favorite 2 Fiction books and 1 Mystery book
        // Fiction frequency = 2, Mystery frequency = 1
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '2', '4'],
          dataSource: dataSource,
        );

        // Fiction books (freq=2) should come before Mystery books (freq=1)
        final fictionIdx = results.indexWhere((b) => b.genre == 'Fiction');
        final mysteryIdx = results.indexWhere((b) => b.genre == 'Mystery');

        if (fictionIdx >= 0 && mysteryIdx >= 0) {
          expect(fictionIdx, lessThan(mysteryIdx));
        }
      });

      test('sorts alphabetically by genre name for tied frequencies',
          () async {
        // Favorite 1 Fiction book (id: 1) and 1 Mystery book (id: 4)
        // Both genres have frequency = 1
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '4'],
          dataSource: dataSource,
        );

        // Find first Fiction and first Mystery recommendation
        final genres = results.map((b) => b.genre).toList();
        final firstFictionIdx = genres.indexOf('Fiction');
        final firstMysteryIdx = genres.indexOf('Mystery');

        // "Fiction" comes before "Mystery" alphabetically
        if (firstFictionIdx >= 0 && firstMysteryIdx >= 0) {
          expect(firstFictionIdx, lessThan(firstMysteryIdx));
        }
      });

      test('returns empty when all genre books are already favorited',
          () async {
        // Favorite all Fiction books
        final dataSource = TestDataSource([
          const Book(
            id: '1',
            title: 'Only Fiction A',
            author: 'Author A',
            genre: 'Fiction',
            description: 'Fiction book.',
          ),
          const Book(
            id: '2',
            title: 'Only Fiction B',
            author: 'Author B',
            genre: 'Fiction',
            description: 'Another fiction book.',
          ),
        ]);

        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '2'],
          dataSource: dataSource,
        );

        expect(results, isEmpty);
      });

      test('handles favorite IDs not found in catalog gracefully', () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['non-existent-id'],
          dataSource: dataSource,
        );

        // Falls back to default recommendations
        expect(results.length, lessThanOrEqualTo(5));
      });

      test('recommendations share at least one genre with favorites',
          () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '6'],
          dataSource: dataSource,
        );

        // Genres from favorites: Fiction, Science Fiction
        final favoriteGenres = {'Fiction', 'Science Fiction'};
        for (final book in results) {
          expect(favoriteGenres.contains(book.genre), isTrue);
        }
      });
    });

    group('without favorites (empty favorites list)', () {
      test('returns up to 5 books from genres with most available books',
          () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: [],
          dataSource: dataSource,
        );

        expect(results.length, lessThanOrEqualTo(5));
        expect(results, isNotEmpty);
      });

      test('prioritizes genres with the most books', () async {
        // Fiction has 3 books, others have 2 each
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: [],
          dataSource: dataSource,
        );

        // First recommendations should come from Fiction (3 books, most populous)
        expect(results.first.genre, equals('Fiction'));
      });

      test('returns empty list when catalog is empty', () async {
        final dataSource = TestDataSource([]);
        final results = await service.getRecommendations(
          favoriteBookIds: [],
          dataSource: dataSource,
        );

        expect(results, isEmpty);
      });

      test('returns fewer than 5 when catalog has fewer books', () async {
        final dataSource = TestDataSource([
          const Book(
            id: '1',
            title: 'Only Book',
            author: 'Author',
            genre: 'Fiction',
            description: 'The only book.',
          ),
        ]);

        final results = await service.getRecommendations(
          favoriteBookIds: [],
          dataSource: dataSource,
        );

        expect(results.length, equals(1));
      });
    });

    group('edge cases', () {
      test('handles single book in catalog that is favorited', () async {
        final dataSource = TestDataSource([
          const Book(
            id: '1',
            title: 'Only Book',
            author: 'Author',
            genre: 'Fiction',
            description: 'The only book.',
          ),
        ]);

        final results = await service.getRecommendations(
          favoriteBookIds: ['1'],
          dataSource: dataSource,
        );

        expect(results, isEmpty);
      });

      test('handles duplicate favorite IDs gracefully', () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1', '1', '1'],
          dataSource: dataSource,
        );

        // Should still work, with Fiction having freq = 3
        expect(results.length, lessThanOrEqualTo(5));
        final resultIds = results.map((b) => b.id).toSet();
        expect(resultIds.contains('1'), isFalse);
      });

      test('within same genre, books are sorted by title alphabetically',
          () async {
        final dataSource = TestDataSource(sampleBooks);
        final results = await service.getRecommendations(
          favoriteBookIds: ['1'],
          dataSource: dataSource,
        );

        // Remaining Fiction books should be sorted by title
        for (int i = 0; i < results.length - 1; i++) {
          if (results[i].genre == results[i + 1].genre) {
            expect(
              results[i].title.compareTo(results[i + 1].title),
              lessThanOrEqualTo(0),
            );
          }
        }
      });
    });
  });
}
