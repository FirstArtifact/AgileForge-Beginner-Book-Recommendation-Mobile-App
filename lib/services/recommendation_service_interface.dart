import '../models/book.dart';
import 'book_data_source.dart';

/// Abstract interface for generating book recommendations.
///
/// Recommendations are based on the genres of favorited books,
/// ranked by genre frequency, excluding already-favorited books,
/// and capped at 5 results.
abstract class RecommendationServiceInterface {
  /// Returns up to 5 recommended books based on [favoriteBookIds].
  ///
  /// Uses [dataSource] to access the full book catalog for
  /// genre analysis and candidate selection.
  Future<List<Book>> getRecommendations({
    required List<String> favoriteBookIds,
    required BookDataSource dataSource,
  });
}
