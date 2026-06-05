/// Supabase connection configuration.
///
/// This file holds the Supabase project URL and anonymous API key needed
/// to initialize the `supabase_flutter` client. Both values are read from
/// environment variables so they are not committed to source control.
///
/// ## Where to find your credentials
///
/// 1. Log in to https://app.supabase.com
/// 2. Select (or create) your project
/// 3. Navigate to **Settings > API** in the left sidebar
/// 4. Copy the **Project URL** → use as SUPABASE_URL
/// 5. Copy the **anon / public** key → use as SUPABASE_ANON_KEY
///
/// ## Passing environment variables in Flutter
///
/// Use `--dart-define` when running or building:
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
///
/// See: https://pub.dev/packages/supabase_flutter#initialization
library;

/// Configuration holder for Supabase connection credentials.
///
/// This class does NOT initialize the Supabase client itself — it simply
/// provides the URL and key values so that the client can be initialized
/// elsewhere (e.g., in `main.dart` during app startup).
class SupabaseConfig {
  /// The Supabase project URL.
  ///
  /// Found in Supabase Dashboard → Settings → API → Project URL.
  /// Pass via: `--dart-define=SUPABASE_URL=https://your-project.supabase.co`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-ref.supabase.co', // placeholder
  );

  /// The Supabase anonymous (public) API key.
  ///
  /// Found in Supabase Dashboard → Settings → API → anon / public key.
  /// Pass via: `--dart-define=SUPABASE_ANON_KEY=your-anon-key`
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here', // placeholder
  );

  /// Connection timeout duration in seconds.
  ///
  /// If the Supabase client cannot establish a connection within this
  /// duration, the app falls back to [MockDataService].
  static const int connectionTimeoutSeconds = 10;

  /// Whether the current configuration contains placeholder values.
  ///
  /// Returns `true` when the developer has not yet supplied real
  /// credentials via `--dart-define`. This is useful for deciding
  /// whether to even attempt a Supabase connection.
  static bool get hasPlaceholderCredentials =>
      supabaseUrl.contains('your-project-ref') ||
      supabaseAnonKey.contains('your-anon-key-here');
}
