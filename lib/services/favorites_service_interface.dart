/// Abstract interface for managing book favorites.
///
/// Implementations handle persistence of favorite book IDs
/// (e.g., via shared_preferences) and provide immediate
/// optimistic updates with rollback on failure.
abstract class FavoritesServiceInterface {
  /// Returns the list of favorited book IDs, ordered by most recently added first.
  Future<List<String>> getFavoriteIds();

  /// Adds [bookId] to the favorites list.
  Future<void> addFavorite(String bookId);

  /// Removes [bookId] from the favorites list.
  Future<void> removeFavorite(String bookId);

  /// Returns true if [bookId] is currently in the favorites list.
  Future<bool> isFavorite(String bookId);
}
