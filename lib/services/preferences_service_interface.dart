/// Abstract interface for managing user preferences.
///
/// Handles persistence of user preference settings such as
/// the selected genre filter, using shared_preferences as
/// the storage backend.
abstract class PreferencesServiceInterface {
  /// Returns the currently stored genre filter, or null for "All".
  Future<String?> getSelectedGenre();

  /// Persists the selected genre filter. Pass null to clear (select "All").
  Future<void> setSelectedGenre(String? genre);

  /// Clears all stored preferences, resetting to defaults.
  Future<void> clearPreferences();
}
