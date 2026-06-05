/// Reference Implementation
///
/// Book List Screen — displays a scrollable list of books with genre filter chips.
///
/// ## State Management Pattern (Riverpod)
///
/// This screen uses [ConsumerWidget] from Riverpod, which provides a [WidgetRef]
/// for watching providers. The widget rebuilds automatically when any watched
/// provider's state changes — no manual subscription or dispose logic needed.
///
/// Providers consumed:
/// - [filteredBooksProvider]: The book list, already sorted alphabetically and
///   filtered by the selected genre. Returns an [AsyncValue] so we can handle
///   loading/error/data states declaratively.
/// - [genreListProvider]: Unique genres extracted from the full book catalog.
/// - [selectedGenreProvider]: The currently active genre filter (null = "All").
/// - [favoritesProvider]: List of favorited book IDs, used to show heart icons.
///
/// ## UI Reactivity
///
/// Because Riverpod providers form a reactive dependency graph, selecting a new
/// genre chip triggers this chain:
///   1. User taps chip → calls `ref.read(selectedGenreProvider.notifier).selectGenre(genre)`
///   2. [selectedGenreProvider] state updates to the new genre
///   3. [filteredBooksProvider] watches [selectedGenreProvider], so it recomputes
///   4. This widget watches [filteredBooksProvider], so it rebuilds with new data
///
/// No imperative "refresh" call is needed — the reactive graph handles propagation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../providers/book_providers.dart';
import '../providers/favorites_provider.dart';
import '../utils/text_utils.dart';

/// The main book browsing screen with genre filtering.
///
/// Displays a vertically scrollable list of books and a horizontal row of
/// genre filter chips at the top. Each book item shows title (truncated at
/// 50 chars), author, genre, and a filled heart icon if favorited.
class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered books provider — returns AsyncValue<List<Book>>
    // which encapsulates loading, error, and data states.
    final filteredBooksAsync = ref.watch(filteredBooksProvider);

    // Watch genre list for building filter chips.
    final genres = ref.watch(genreListProvider);

    // Watch selected genre to highlight the active chip.
    final selectedGenre = ref.watch(selectedGenreProvider);

    // Watch favorites to determine which books show a heart icon.
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Genre Filter Chips ──────────────────────────────────────
            // Horizontally scrollable row of genre chips with an "All" option.
            // The selected chip uses a filled/elevated style that is
            // identifiable without relying on color alone (accessibility best practice).
            _GenreFilterChips(
              genres: genres,
              selectedGenre: selectedGenre,
              onGenreSelected: (genre) {
                // Update the selected genre via the notifier.
                // Setting null clears the filter (shows all books).
                ref.read(selectedGenreProvider.notifier).selectGenre(genre);
              },
            ),

            // ─── Book List Content ───────────────────────────────────────
            // Uses AsyncValue.when() to declaratively render loading, error,
            // and data states without manual state tracking.
            Expanded(
              child: filteredBooksAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load books',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (books) {
                  // Empty state: show message when no books match filter
                  // or when data source returns no books.
                  if (books.isEmpty) {
                    return _EmptyBooksState(
                      hasFilter: selectedGenre != null,
                    );
                  }

                  // Render the scrollable book list.
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isFavorite = favoriteIds.contains(book.id);

                      return _BookListItem(
                        book: book,
                        isFavorite: isFavorite,
                        onTap: () {
                          // Navigate to book detail within the current tab's
                          // navigation stack using go_router path parameters.
                          context.go('/books/${book.id}');
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable row of genre filter chips.
///
/// Includes an "All" chip that clears the genre filter, followed by one chip
/// per available genre. The selected chip is visually distinguished using a
/// filled style with elevation, making it identifiable without relying on
/// color alone (uses shape and elevation differences for accessibility).
class _GenreFilterChips extends StatelessWidget {
  const _GenreFilterChips({
    required this.genres,
    required this.selectedGenre,
    required this.onGenreSelected,
  });

  final List<String> genres;
  final String? selectedGenre;
  final ValueChanged<String?> onGenreSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            // "All" chip — selected when no genre filter is active.
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedGenre == null,
                // Selected chip uses filled style with elevation for
                // non-color-dependent visual distinction (accessibility).
                showCheckmark: true,
                elevation: selectedGenre == null ? 4.0 : 0.0,
                onSelected: (_) => onGenreSelected(null),
              ),
            ),
            // One chip per genre from the data source.
            ...genres.map((genre) {
              final isSelected = selectedGenre == genre;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  showCheckmark: true,
                  elevation: isSelected ? 4.0 : 0.0,
                  onSelected: (_) => onGenreSelected(genre),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// A single book item in the list.
///
/// Displays the book title (truncated at 50 characters), author, genre,
/// and a filled heart icon if the book is in the user's favorites.
class _BookListItem extends StatelessWidget {
  const _BookListItem({
    required this.book,
    required this.isFavorite,
    required this.onTap,
  });

  final Book book;
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: onTap,
        // Title: truncated at 50 characters for readability.
        title: Text(
          truncateText(book.title, 50),
          style: theme.textTheme.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.author,
              style: theme.textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.genre,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        // Filled heart icon on favorited books.
        trailing: isFavorite
            ? Icon(
                Icons.favorite,
                color: theme.colorScheme.error,
                semanticLabel: 'Favorited',
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}

/// Empty state widget displayed when no books are available or no books
/// match the current genre filter.
class _EmptyBooksState extends StatelessWidget {
  const _EmptyBooksState({required this.hasFilter});

  /// Whether a genre filter is currently active — changes the message.
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasFilter ? Icons.filter_list_off : Icons.menu_book_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'No books match the selected genre'
                  : 'No books available',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try selecting a different genre or tap "All" to see all books.'
                  : 'Check back later for new additions.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
