/// Scaffolded Stub
///
/// Riverpod provider for favorites state management.
///
/// This file teaches the optimistic update pattern with Riverpod StateNotifier.
///
/// The [FavoritesNotifier] should perform optimistic updates — the UI state is
/// updated immediately and rolled back if the underlying persistence operation
/// fails. Loading favorites from storage is already implemented. Your task is
/// to implement [addFavorite] and [removeFavorite] using the optimistic update
/// + rollback pattern described in the TODO comments.
///
/// Riverpod pattern: StateNotifierProvider encapsulates state + mutation logic.
/// Widgets watch the provider for the current list of favorite IDs, and call
/// notifier methods (addFavorite / removeFavorite) to trigger state changes.
/// Because other providers (like recommendationsProvider) watch this provider,
/// changes to favorites automatically trigger recommendation regeneration.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/favorites_service.dart';
import '../services/favorites_service_interface.dart';

// ---------------------------------------------------------------------------
// favoritesProvider
// ---------------------------------------------------------------------------

/// Provides the list of favorite book IDs and exposes mutation methods.
///
/// State value: `List<String>` of book IDs ordered by most recently added first.
///
/// Riverpod pattern: [StateNotifierProvider] is used here because favorites
/// require complex mutation logic (optimistic updates + rollback on failure)
/// that goes beyond simple state assignment. The notifier encapsulates this
/// logic, keeping widgets and other providers focused on reading state.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier();
});

/// StateNotifier managing the favorites list with optimistic updates.
///
/// On initialization, loads persisted favorites from [FavoritesService].
/// Mutation methods ([addFavorite], [removeFavorite]) apply changes
/// optimistically to the state, persist via [FavoritesService], and
/// rollback the state if persistence fails.
///
/// Persistence failures are exposed by rethrowing the exception so that
/// UI layers can catch it and display a SnackBar error message
/// so the UI can display a SnackBar error to the user.
class FavoritesNotifier extends StateNotifier<List<String>> {
  final FavoritesServiceInterface _favoritesService;

  FavoritesNotifier({FavoritesServiceInterface? favoritesService})
      : _favoritesService = favoritesService ?? FavoritesService(),
        super(<String>[]) {
    // Load persisted favorites on initialization.
    _loadFavorites();
  }

  /// Loads the persisted favorites list from local storage.
  /// Called once during notifier initialization.
  Future<void> _loadFavorites() async {
    try {
      final ids = await _favoritesService.getFavoriteIds();
      state = ids;
    } catch (_) {
      // If loading fails, start with an empty list (graceful degradation).
      state = <String>[];
    }
  }

  /// Adds [bookId] to the favorites list with optimistic update.
  ///
  /// The state is updated immediately (optimistic) so the UI reflects the
  /// change without waiting for persistence. If persistence fails, the
  /// state is rolled back to its previous value and the exception is
  /// rethrown for the UI to handle (e.g., display a SnackBar).
  ///
  /// New favorites are inserted at the front of the list (most recently
  /// added first, for a "most recent" ordering).
  Future<void> addFavorite(String bookId) async {
    // TODO: Implement the optimistic update pattern for adding a favorite.
    // ─────────────────────────────────────────────────────────────────────
    // Steps:
    //   1. Check if bookId is already in state — if yes, return early
    //   2. Save the previous state for rollback
    //   3. Optimistically update state: state = [bookId, ...state] (add to front)
    //   4. Try to persist via _favoritesService.addFavorite(bookId)
    //   5. If persist fails: rollback state = previousState and rethrow
    // ─────────────────────────────────────────────────────────────────────
    //
    // Hint:
    // final previousState = state;
    // state = [bookId, ...state];  // optimistic
    // try {
    //   await _favoritesService.addFavorite(bookId);
    // } catch (e) {
    //   state = previousState;  // rollback
    //   rethrow;
    // }

    return; // Placeholder — does nothing until implemented
  }

  /// Removes [bookId] from the favorites list with optimistic update.
  ///
  /// The state is updated immediately (optimistic). If persistence fails,
  /// the state is rolled back to its previous value and the exception is
  /// rethrown for the UI to handle.
  Future<void> removeFavorite(String bookId) async {
    // TODO: Implement the optimistic update pattern for removing a favorite.
    // ─────────────────────────────────────────────────────────────────────
    // Steps:
    //   1. Check if bookId is in state — if not, return early
    //   2. Save the previous state for rollback
    //   3. Optimistically remove: state = state.where((id) => id != bookId).toList()
    //   4. Try to persist via _favoritesService.removeFavorite(bookId)
    //   5. If persist fails: rollback state = previousState and rethrow
    // ─────────────────────────────────────────────────────────────────────

    return; // Placeholder — does nothing until implemented
  }
}
