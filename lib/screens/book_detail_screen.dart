/// Reference Implementation
///
/// Book Detail Screen — displays detailed information about a selected book
/// with a favorite toggle button.
///
/// ## State Management Pattern (Riverpod)
///
/// This screen uses [ConsumerWidget] to watch:
/// - [allBooksProvider]: To retrieve the full book by its ID.
/// - [favoritesProvider]: To determine if the book is currently favorited
///   and to toggle the favorite state.
///
/// ## Favorite Toggle Flow
///
/// When the user taps the heart icon:
///   1. Call `ref.read(favoritesProvider.notifier).addFavorite(bookId)` or
///      `.removeFavorite(bookId)` depending on current state.
///   2. The [favoritesProvider] performs an optimistic update (state changes
///      immediately) and persists to shared_preferences.
///   3. If persistence fails, the notifier rolls back state and rethrows.
///   4. The catch block shows a SnackBar error message to inform the user.
///
/// ## Navigation
///
/// Back navigation is handled automatically by go_router. Because the router
/// uses [StatefulShellRoute], each tab maintains its own navigation stack.
/// Pressing back returns to the previous screen within the same tab,
/// preserving filter state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../providers/book_providers.dart';
import '../providers/favorites_provider.dart';
import '../utils/text_utils.dart';

/// Displays detailed information about a single book.
///
/// Requires a [bookId] parameter passed via go_router path parameters.
/// Shows title, author, genre, publish year (if available), and description
/// (truncated at 500 characters). Includes a favorite toggle heart button
/// with immediate state update.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.bookId});

  /// The unique identifier of the book to display.
  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch allBooksProvider to find the book by ID.
    final allBooksAsync = ref.watch(allBooksProvider);

    // Watch favorites to determine the current favorite state.
    final favoriteIds = ref.watch(favoritesProvider);

    final theme = Theme.of(context);

    return allBooksAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Book Detail')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Book Detail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load book details',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (books) {
        // Find the book by ID from the full list.
        final Book? book = books.cast<Book?>().firstWhere(
              (b) => b!.id == bookId,
              orElse: () => null,
            );

        if (book == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Book Detail')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.book_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Book not found',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isFavorite = favoriteIds.contains(book.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(book.title),
            actions: [
              // Favorite toggle button — filled heart if favorited,
              // outline heart if not.
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? theme.colorScheme.error : null,
                ),
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: () => _toggleFavorite(context, ref, isFavorite),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Title ─────────────────────────────────────────────
                Text(
                  book.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ─── Author ────────────────────────────────────────────
                Text(
                  'by ${book.author}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Genre ─────────────────────────────────────────────
                Chip(
                  label: Text(book.genre),
                  avatar: const Icon(Icons.category_outlined, size: 18),
                ),
                const SizedBox(height: 12),

                // ─── Publish Year (if available) ───────────────────────
                if (book.publishYear != null) ...[
                  Text(
                    'Published: ${book.publishYear}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                const Divider(),
                const SizedBox(height: 16),

                // ─── Description (truncated at 500 chars) ──────────────
                // Truncate at 500 characters with
                // indication if text was truncated.
                Text(
                  'Description',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  truncateText(book.description, 500),
                  style: theme.textTheme.bodyLarge,
                ),
                // Show truncation indicator if description exceeds 500 chars.
                if (book.description.length > 500) ...[
                  const SizedBox(height: 4),
                  Text(
                    '...read more',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Toggles the favorite state for the current book.
  ///
  /// Catches persistence failures and displays a SnackBar error message
  /// The [FavoritesNotifier] handles optimistic updates
  /// and rollback internally.
  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
  ) async {
    try {
      if (isFavorite) {
        await ref.read(favoritesProvider.notifier).removeFavorite(bookId);
      } else {
        await ref.read(favoritesProvider.notifier).addFavorite(bookId);
      }
    } catch (e) {
      // Show error SnackBar on persistence failure.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? 'Failed to remove from favorites'
                  : 'Failed to add to favorites',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
