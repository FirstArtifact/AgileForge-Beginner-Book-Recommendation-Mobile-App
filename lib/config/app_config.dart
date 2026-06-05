/// Application configuration for toggling between data sources.
///
/// The [useRealApi] flag determines whether the app uses the real
/// Open Library API (via ApiServiceStub) or the offline MockDataService.
/// This flag defaults to `false` so the app works out of the box with
/// mock data — learners can set it to `true` after implementing the
/// API_Service_Stub as part of their learning exercise.
///
/// When [useRealApi] is `true` AND real Supabase credentials are provided
/// (via --dart-define), the app will also attempt to initialize Supabase
/// on startup. If that connection fails within the configured timeout,
/// the app automatically falls back to MockDataService and shows a
/// connectivity warning banner.
library;

/// Holds global application configuration flags.
class AppConfig {
  /// When `true`, the app routes data requests through [ApiServiceStub]
  /// (the learner-implemented Open Library API integration) and attempts
  /// to initialize the Supabase backend connection on startup.
  ///
  /// When `false` (default), the app uses [MockDataService] for offline data
  /// and skips Supabase initialization entirely — no network calls are made.
  ///
  /// ────────────────────────────────────────────────────────────────────────
  /// HOW TO ENABLE REAL API / SUPABASE:
  ///   1. Implement the methods in `lib/services/api_service_stub.dart`
  ///   2. Set your Supabase credentials via --dart-define (see supabase_config.dart)
  ///   3. Change the default below from `false` to `true`
  ///   4. Hot-restart the app (hot-reload is not sufficient for main.dart changes)
  /// ────────────────────────────────────────────────────────────────────────
  final bool useRealApi;

  const AppConfig({
    this.useRealApi = false, // ← Set to `true` to enable real API & Supabase
  });
}
