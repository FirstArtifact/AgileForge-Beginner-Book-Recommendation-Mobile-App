/// Reference Implementation
///
/// Favorites Screen — displays the user's favorited books ordered by most
/// recently added first.
///
/// This screen demonstrates several Riverpod patterns:
/// - **ConsumerWidget**: A widget that can watch providers without a separate
///   ConsumerStatefulWidget. Ideal for screens that only read state.
/// - **Multiple provider watching**: Watches both [favoritesProvider] (for IDs)
///   and [allBooksProvider] (for Book objects), combining them to render the
///   favorites list.
/// - **Reactive updates**: When the user adds or removes a favorite from the
///   Book Detail Screen, this screen automatically re-renders because it
///   watches the favoritesProvider.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/book_providers.dart';
import '../providers/favorites_provider.dart';
import '../utils/text_utils.dart';

/// Screen displaying the user's favorite books.
///
/// Watches [favoritesProvider] to get the list of favorite book IDs (ordered
/// by most recently added first) and [allBooksProvider] to resolve those IDs
/// into full [Book] objects for display.
///
/// Empty state: When no favorites exist, displays a centered column with a
/// heart icon and a prompt to browse books.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the favorites list (List<String> of book IDs, most recent first).
    final favoriteIds = ref.watch(favoritesProvider);

    // Watch all books to resolve favorite IDs into Book objects.
    final allBooksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: allBooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading books: $error'),
        ),
        data: (allBooks) {
          // Resolve favorite IDs to Book objects, preserving the order from
          // favoritesProvider (most recently added first).
          final favoriteBooks = _resolveFavoriteBooks(favoriteIds, allBooks);

          // Show empty state if no favorites exist.
          if (favoriteBooks.isEmpty) {
            return _buildEmptyState(context);
          }

          // Display the favorites list.
          return ListView.builder(
            itemCount: favoriteBooks.length,
            itemBuilder: (context, index) {
              final book = favoriteBooks[index];
              return _buildBookListItem(context, book);
            },
          );
        },
      ),
    );
  }

  /// Resolves a list of favorite book IDs into a list of [Book] objects,
  /// preserving the order of [favoriteIds] (most recently added first).
  ///
  /// Books whose IDs are not found in [allBooks] are silently skipped.
  /// This handles the edge case where a book ID is stored in favorites
  /// but the data source no longer contains that book.
  List<Book> _resolveFavoriteBooks(
    List<String> favoriteIds,
    List<Book> allBooks,
  ) {
    // Build a lookup map for O(1) book resolution by ID.
    final bookMap = {for (final book in allBooks) book.id: book};

    // Map IDs to books, skipping any that aren't found in the data source.
    return favoriteIds
        .where((id) => bookMap.containsKey(id))
        .map((id) => bookMap[id]!)
        .toList();
  }

  /// Builds the empty state displayed when the user has no favorites.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse books to add some!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// Builds a single book list item matching the Book List Screen style.
  ///
  /// Displays book title (truncated at 50 chars), author, and genre.
  /// Tapping navigates to the Book Detail Screen within the favorites tab.
  Widget _buildBookListItem(BuildContext context, Book book) {
    return ListTile(
      title: Text(
        truncateText(book.title, 50),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${book.author} • ${book.genre}'),
      trailing: Icon(
        Icons.favorite,
        color: Theme.of(context).colorScheme.error,
      ),
      onTap: () {
        // Navigate to Book Detail within the favorites tab stack.
        // This uses go_router's nested route: /favorites/:id
        context.go('/favorites/${book.id}');
      },
    );
  }
}
