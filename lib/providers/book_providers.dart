/// Reference Implementation
///
/// Riverpod providers for book-related state management.
///
/// This file demonstrates several key Riverpod patterns:
/// - **Provider**: For creating singleton service instances (bookDataSourceProvider)
/// - **FutureProvider**: For async data fetching (allBooksProvider)
/// - **Derived Provider**: For computed/filtered state (filteredBooksProvider, genreListProvider)
/// - **StateNotifierProvider**: For mutable state with business logic (selectedGenreProvider)
///
/// Riverpod's reactive graph means that when a provider's dependency changes,
/// all providers that depend on it automatically recompute. For example, when
/// `selectedGenreProvider` changes, `filteredBooksProvider` recomputes because
/// it watches `selectedGenreProvider`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/book.dart';
import '../services/book_data_source.dart';
import '../services/book_repository.dart';
import '../services/mock_data_service.dart';
import '../services/preferences_service.dart';

// ---------------------------------------------------------------------------
// bookDataSourceProvider
// ---------------------------------------------------------------------------

/// Provides the active [BookDataSource] instance for the entire app.
///
/// This is the root of the book data dependency graph. All providers that
/// need book data depend on this provider, which ensures a single source
/// of truth for data access configuration.
///
/// Riverpod pattern: A simple [Provider] is used here because the data source
/// is determined once at startup and does not change during the app lifecycle.
final bookDataSourceProvider = Provider<BookDataSource>((ref) {
  // AppConfig defaults useRealApi to false, so MockDataService is used.
  // When a learner implements ApiServiceStub and flips the flag, the
  // repository automatically routes to the real API.
  const config = AppConfig();
  final mockService = MockDataService();
  return BookRepository(config: config, mockService: mockService);
});

// ---------------------------------------------------------------------------
// allBooksProvider
// ---------------------------------------------------------------------------

/// Fetches all books from the active data source.
///
/// Riverpod pattern: [FutureProvider] is ideal for one-shot async operations.
/// The framework handles loading/error/data states automatically — widgets
/// can use `.when(data:, loading:, error:)` to render each state.
///
/// This provider watches [bookDataSourceProvider], so if the data source
/// ever changes (e.g., hot-restart with a different config), it refetches.
final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final dataSource = ref.watch(bookDataSourceProvider);
  return dataSource.getAllBooks();
});

// ---------------------------------------------------------------------------
// selectedGenreProvider
// ---------------------------------------------------------------------------

/// Manages the currently selected genre filter with persistence.
///
/// Riverpod pattern: [StateNotifierProvider] separates mutable state from
/// the business logic that governs state transitions. The [GenreNotifier]
/// encapsulates the logic for selecting a genre and persisting the choice
/// to [PreferencesService], keeping providers and widgets focused on their
/// own responsibilities.
///
/// State value: `null` means "All" (no filter), a non-null String is the
/// selected genre name.
final selectedGenreProvider =
    StateNotifierProvider<GenreNotifier, String?>((ref) {
  return GenreNotifier();
});

/// StateNotifier that holds the selected genre and persists changes.
///
/// Using a StateNotifier (rather than a simple StateProvider) lets us:
/// 1. Add side effects (persistence) when state changes
/// 2. Validate state transitions
/// 3. Keep the mutation logic testable in isolation
class GenreNotifier extends StateNotifier<String?> {
  final PreferencesService _preferencesService;

  GenreNotifier({PreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? PreferencesService(),
        super(null) {
    // Load the previously persisted genre on initialization.
    _loadPersistedGenre();
  }

  /// Loads the persisted genre preference from local storage.
  /// Called once during notifier initialization.
  Future<void> _loadPersistedGenre() async {
    final persistedGenre = await _preferencesService.getSelectedGenre();
    state = persistedGenre;
  }

  /// Updates the selected genre filter and persists the new value.
  ///
  /// Pass `null` to select "All" (clear filter).
  /// Pass a genre name string to filter by that genre.
  Future<void> selectGenre(String? genre) async {
    state = genre;
    // Persist the selection so it survives app restarts.
    await _preferencesService.setSelectedGenre(genre);
  }
}

// ---------------------------------------------------------------------------
// filteredBooksProvider
// ---------------------------------------------------------------------------

/// Provides the book list filtered by the selected genre and sorted
/// alphabetically by title.
///
/// Riverpod pattern: A derived [Provider] that watches two other providers
/// ([allBooksProvider] and [selectedGenreProvider]). Riverpod's dependency
/// graph ensures this provider automatically recomputes whenever either
/// dependency changes — no manual subscription management needed.
///
/// Returns an [AsyncValue] to preserve the loading/error states from
/// [allBooksProvider] while applying the genre filter on top.
final filteredBooksProvider = Provider<AsyncValue<List<Book>>>((ref) {
  final allBooksAsync = ref.watch(allBooksProvider);
  final selectedGenre = ref.watch(selectedGenreProvider);

  // Map over the AsyncValue to apply filtering and sorting while
  // preserving loading/error states from the upstream provider.
  return allBooksAsync.whenData((books) {
    // Filter by genre if one is selected; show all if null ("All").
    final filtered = selectedGenre == null
        ? books
        : books.where((book) => book.genre == selectedGenre).toList();

    // Sort alphabetically by title (case-insensitive) for consistent display.
    filtered.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );

    return filtered;
  });
});

// ---------------------------------------------------------------------------
// genreListProvider
// ---------------------------------------------------------------------------

/// Extracts unique genres from the full book list.
///
/// Riverpod pattern: Another derived [Provider] that watches [allBooksProvider].
/// By deriving genre options from the actual data, the filter chips always
/// reflect what's available — if the data source changes, genres update
/// automatically.
///
/// Returns an empty list while books are loading or on error, so the UI
/// can gracefully handle those states.
final genreListProvider = Provider<List<String>>((ref) {
  final allBooksAsync = ref.watch(allBooksProvider);

  return allBooksAsync.when(
    data: (books) {
      // Extract unique genres and sort alphabetically for consistent display.
      final genres = books.map((book) => book.genre).toSet().toList()..sort();
      return genres;
    },
    loading: () => <String>[],
    error: (_, _) => <String>[],
  );
});
