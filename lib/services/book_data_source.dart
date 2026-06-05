import '../models/book.dart';

/// Abstract data source interface for book operations.
///
/// All data sources (MockDataService, ApiServiceStub, SupabaseService)
/// implement this interface, enabling seamless swapping between
/// implementations via a single configuration flag.
abstract class BookDataSource {
  /// Returns all books from the data source.
  Future<List<Book>> getAllBooks();

  /// Returns books filtered by the specified [genre].
  Future<List<Book>> getBooksByGenre(String genre);

  /// Returns books matching the search [query] against title or author.
  Future<List<Book>> searchBooks(String query);

  /// Returns a single book by its [id], or null if not found.
  Future<Book?> getBookById(String id);
}
