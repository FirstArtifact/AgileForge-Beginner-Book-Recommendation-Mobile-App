/// Scaffolded Stub
///
/// Manages user preference persistence using shared_preferences.
/// The selected genre filter is stored under the key `selected_genre` as a
/// nullable String value — null represents "All" (no filter applied).
///
/// ─────────────────────────────────────────────────────────────────────────────
/// 🟢 RECOMMENDED FIRST EXERCISE
///
/// This is the simplest service in the app — a great warm-up for learners.
/// It introduces the basic SharedPreferences persistence pattern:
///   1. Get the SharedPreferences instance
///   2. Read, write, or remove a single key
///
/// The app works without this implementation (genre filter just won't persist
/// across restarts), so you can implement and test incrementally.
/// ─────────────────────────────────────────────────────────────────────────────
library;

// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences_service_interface.dart';

/// Concrete implementation of [PreferencesServiceInterface] using shared_preferences.
class PreferencesService implements PreferencesServiceInterface {
  /// The shared_preferences key used to store the selected genre filter.
  // ignore: unused_field
  static const String _genreKey = 'selected_genre';

  /// Returns the currently stored genre filter, or null for "All".
  ///
  /// Reads the string value stored under [_genreKey] in SharedPreferences.
  /// Returns null if no genre has been saved (meaning "All" / no filter).
  @override
  Future<String?> getSelectedGenre() async {
    // TODO: Get SharedPreferences instance, read the string stored under
    //       `_genreKey`, and return it (null means "All" / no filter).
    //
    // Hint:
    //   final prefs = await SharedPreferences.getInstance();
    //   return prefs.getString(_genreKey);

    return null; // Placeholder: always returns null ("All" — no filter applied)
  }

  /// Persists the selected genre filter. Pass null to clear (select "All").
  ///
  /// If [genre] is null, removes the key from storage (resetting to "All").
  /// Otherwise, stores the genre string under [_genreKey].
  @override
  Future<void> setSelectedGenre(String? genre) async {
    // TODO: Get SharedPreferences instance. If genre is null, remove the key.
    //       Otherwise, set the string value under `_genreKey`.
    //
    // Hint:
    //   final prefs = await SharedPreferences.getInstance();
    //   if (genre == null) {
    //     await prefs.remove(_genreKey);
    //   } else {
    //     await prefs.setString(_genreKey, genre);
    //   }

    return; // Placeholder: does nothing (preference won't persist)
  }

  /// Clears all stored preferences, resetting to defaults.
  ///
  /// Removes the [_genreKey] from SharedPreferences so the genre filter
  /// reverts to "All" on next read.
  @override
  Future<void> clearPreferences() async {
    // TODO: Get SharedPreferences instance and remove the `_genreKey`.
    //
    // Hint:
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.remove(_genreKey);

    return; // Placeholder: does nothing (preferences are not cleared)
  }
}
