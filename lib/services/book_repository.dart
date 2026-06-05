/// Reference Implementation
///
/// The [BookRepository] delegates all data operations to either
/// [MockDataService] or [ApiServiceStub] based on the [AppConfig.useRealApi]
/// flag. This abstraction allows the app to seamlessly switch between
/// offline mock data and real API calls without changing any consumer code.
///
/// Since [useRealApi] defaults to `false`, the repository uses
/// [MockDataService] out of the box. Once a learner implements the
/// ApiServiceStub, they flip the flag to switch data sources.
library;

import '../config/app_config.dart';
import '../models/book.dart';
import 'book_data_source.dart';
import 'mock_data_service.dart';

/// Repository that implements [BookDataSource] by delegating to the
/// currently active data source based on application configuration.
///
/// This is the single entry point for all book data access in the app.
/// Screens and providers never interact with MockDataService or ApiServiceStub
/// directly — they go through this repository, making the data source
/// transparent to consumers.
class BookRepository implements BookDataSource {
  /// The active data source selected based on [AppConfig.useRealApi].
  final BookDataSource _activeSource;

  /// Creates a [BookRepository] that selects its data source based on [config].
  ///
  /// - If [config.useRealApi] is `true`, uses ApiServiceStub (learner exercise).
  /// - If [config.useRealApi] is `false` (default), uses [mockService].
  ///
  /// Note: ApiServiceStub is not yet implemented. When `useRealApi` is false,
  /// the repository simply delegates to the provided [mockService].
  BookRepository({
    required AppConfig config,
    required MockDataService mockService,
  }) : _activeSource = config.useRealApi
            ? mockService // TODO: Replace with ApiServiceStub() once implemented
            : mockService;

  @override
  Future<List<Book>> getAllBooks() => _activeSource.getAllBooks();

  @override
  Future<List<Book>> getBooksByGenre(String genre) =>
      _activeSource.getBooksByGenre(genre);

  @override
  Future<List<Book>> searchBooks(String query) =>
      _activeSource.searchBooks(query);

  @override
  Future<Book?> getBookById(String id) => _activeSource.getBookById(id);
}
