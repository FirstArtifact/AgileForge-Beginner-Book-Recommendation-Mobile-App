/// Reference Implementation
///
/// Riverpod provider for the PreferencesService instance.
///
/// This file demonstrates the simplest Riverpod pattern: a [Provider] that
/// creates and exposes a singleton service instance. Other providers and
/// widgets that need to read or write user preferences can depend on this
/// provider to obtain the [PreferencesService].
///
/// Riverpod pattern: A simple [Provider] is used because PreferencesService
/// is stateless (it delegates to shared_preferences) and does not change
/// during the app lifecycle. This provider enables dependency injection —
/// tests can override it to supply a mock PreferencesService.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';

// ---------------------------------------------------------------------------
// preferencesProvider
// ---------------------------------------------------------------------------

/// Provides a singleton instance of [PreferencesService].
///
/// Widgets and other providers that need to persist or load user preferences
/// (e.g., selected genre filter) should watch or read this provider to
/// obtain the service instance.
///
/// This enables easy testing: override this provider in a [ProviderScope]
/// to inject a mock implementation during widget or integration tests.
final preferencesProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});
