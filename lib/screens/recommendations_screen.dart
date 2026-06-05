/// Reference Implementation
///
/// Recommendations Screen — displays up to 5 genre-based book recommendations.
///
/// This screen demonstrates the [ConsumerWidget] pattern with a [FutureProvider].
/// It watches [recommendationsProvider], which automatically recomputes when
/// the user's favorites change (Riverpod's dependency graph handles this).
///
/// The `.when()` method on [AsyncValue] declaratively handles loading, error,
/// and data states, ensuring the UI always has a defined behavior for each
/// async lifecycle stage.
///
/// ## State Management Pattern
/// - [ConsumerWidget] gives access to `ref` for reading/watching providers
/// - [recommendationsProvider] is a `FutureProvider<List<Book>>` that watches
///   both favoritesProvider and bookDataSourceProvider
/// - When favorites change, recommendations regenerate automatically
///   (no manual refresh needed)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/recommendations_provider.dart';
import '../utils/text_utils.dart';

/// Screen that displays personalized book recommendations based on the user's
/// favorited genres.
///
/// Uses [ConsumerWidget] to watch [recommendationsProvider] and reactively
/// update when recommendations change. Displays up to 5 recommended books
/// with title, author, and genre information.
///
/// Tapping a book navigates to the Book Detail Screen within the
/// recommendations tab's navigation stack.
class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the recommendations provider — triggers rebuild when
    // recommendations change (e.g., when favorites are updated).
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
      ),
      // Use .when() to declaratively handle all async states:
      // - loading: show a progress indicator
      // - error: show an error message with retry option
      // - data: show the list of recommendations or empty state
      body: recommendationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Could not load recommendations.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (books) {
          // Empty state — no recommendations available yet.
          if (books.isEmpty) {
            return _buildEmptyState(context);
          }
          // Display up to 5 recommended books in a list.
          return _buildRecommendationsList(context, books);
        },
      ),
    );
  }

  /// Builds the empty state widget shown when no recommendations are available.
  ///
  /// This typically appears when the user has no favorites, and the
  /// recommendation engine cannot generate suggestions.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              "We'll have recommendations for you once you favorite some books!",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the scrollable list of recommended books.
  ///
  /// Each list item displays the book's title (truncated at 50 chars),
  /// author, and genre. Tapping navigates to the book detail within
  /// the recommendations tab's navigation stack.
  Widget _buildRecommendationsList(BuildContext context, List<Book> books) {
    return ListView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (context, index) {
        final book = books[index];
        return _RecommendationListItem(book: book);
      },
    );
  }
}

/// A single list item in the recommendations list.
///
/// Displays the book's title, author, and genre in a [ListTile] layout.
/// Tapping navigates to `/recommendations/:id` for the book detail screen
/// within the recommendations tab's navigation stack.
class _RecommendationListItem extends StatelessWidget {
  const _RecommendationListItem({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Display truncated title (max 50 characters) as the main text.
      title: Text(
        truncateText(book.title, 50),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // Display author and genre as subtitle.
      subtitle: Text(
        '${book.author} · ${book.genre}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // Leading icon to provide visual consistency with other list screens.
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          Icons.menu_book,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      // Navigate to Book Detail within the recommendations tab stack.
      onTap: () => context.go('/recommendations/${book.id}'),
    );
  }
}
