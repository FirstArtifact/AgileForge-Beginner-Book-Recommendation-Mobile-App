/// Reference Implementation
///
/// Riverpod provider for book recommendations state management.
///
/// This file demonstrates the [FutureProvider] pattern for async data that
/// depends on other providers. The recommendations provider watches both
/// [favoritesProvider] and [bookDataSourceProvider], so whenever the user's
/// favorites change, recommendations automatically regenerate without
/// requiring manual refresh.
///
/// Riverpod pattern: FutureProvider is ideal for derived async data. Because
/// it watches other providers, Riverpod's dependency graph ensures automatic
/// recomputation when upstream state changes. Widgets use `.when()` to handle
/// loading, error, and data states declaratively.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../services/recommendation_service.dart';
import 'book_providers.dart';
import 'favorites_provider.dart';

// ---------------------------------------------------------------------------
// recommendationsProvider
// ---------------------------------------------------------------------------

/// Provides a list of up to 5 recommended books based on the user's favorites.
///
/// This provider watches:
/// - [favoritesProvider]: current list of favorite book IDs
/// - [bookDataSourceProvider]: the active data source for the book catalog
///
/// When either dependency changes, the provider automatically refetches
/// recommendations. This means adding or removing a favorite immediately
/// triggers recommendation regeneration within the same navigation session
/// without requiring an app restart.
///
/// The recommendations algorithm is delegated to [RecommendationService]:
/// - With favorites: returns books from the most frequently favorited genres
/// - Without favorites: returns books from genres with the most available books
/// - Always excludes already-favorited books
/// - Capped at 5 results
final recommendationsProvider = FutureProvider<List<Book>>((ref) async {
  // Watch favorites — triggers recomputation when favorites change.
  final favoriteIds = ref.watch(favoritesProvider);

  // Watch the data source — ensures recommendations use the active source.
  final dataSource = ref.watch(bookDataSourceProvider);

  // Delegate to RecommendationService for the genre-based algorithm.
  final recommendationService = RecommendationService();
  return recommendationService.getRecommendations(
    favoriteBookIds: favoriteIds,
    dataSource: dataSource,
  );
});
