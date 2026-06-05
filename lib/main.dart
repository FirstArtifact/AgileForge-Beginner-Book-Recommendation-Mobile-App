import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/router.dart';
import 'config/supabase_config.dart';
import 'providers/connectivity_provider.dart';

/// Whether the Supabase connection attempt failed during startup.
///
/// This flag is set during [main] and read by the [ProviderScope] overrides
/// so the [supabaseConnectionFailedProvider] reflects the startup result.
bool _supabaseStartupFailed = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt Supabase initialization only when:
  // 1. useRealApi is true (developer opted in), AND
  // 2. Real credentials are provided (not placeholder values)
  //
  // With the default config (useRealApi: false), Supabase init is skipped
  // entirely and the app runs with MockDataService.
  const config = AppConfig(); // useRealApi defaults to false
  if (config.useRealApi && !SupabaseConfig.hasPlaceholderCredentials) {
    _supabaseStartupFailed = await _initializeSupabase();
  }

  runApp(
    ProviderScope(
      overrides: [
        // Seed the connectivity provider with the startup result so the UI
        // can immediately show a MaterialBanner if Supabase failed.
        supabaseConnectionFailedProvider
            .overrideWith((ref) => _supabaseStartupFailed),
      ],
      child: const BookRecommendationApp(),
    ),
  );
}

/// Attempts to initialize the Supabase client with a connection timeout.
///
/// Returns `true` if initialization failed (the app should fall back to
/// MockDataService and show a connectivity warning), or `false` if
/// initialization succeeded.
Future<bool> _initializeSupabase() async {
  try {
    await Future.any([
      Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        // The Supabase publishable key (previously called anonKey).
        // Corresponds to the "anon / public" key in the Supabase dashboard.
        publishableKey: SupabaseConfig.supabaseAnonKey,
      ),
      Future.delayed(
        Duration(seconds: SupabaseConfig.connectionTimeoutSeconds),
        () => throw TimeoutException(
          'Supabase connection timed out after '
          '${SupabaseConfig.connectionTimeoutSeconds} seconds',
        ),
      ),
    ]);
    // Supabase initialized successfully.
    return false;
  } catch (_) {
    // Connection failed or timed out — signal fallback to MockDataService.
    return true;
  }
}

/// Simple timeout exception for Supabase initialization.
class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

/// The root widget of the Book Recommendation teaching shell app.
///
/// Uses Material Design 3 with [ColorScheme.fromSeed] for consistent,
/// accessible theming throughout the application.
///
/// Navigation is handled by go_router via [MaterialApp.router]. The
/// [routerConfig] delegates all route matching, shell rendering, and
/// deep-link handling to the [router] defined in `config/router.dart`.
class BookRecommendationApp extends StatelessWidget {
  const BookRecommendationApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router replaces the standard MaterialApp when using
    // a declarative routing package like go_router. Instead of providing
    // a `home` widget, we supply `routerConfig` which encapsulates all
    // route definitions, redirects, and navigation state.
    return MaterialApp.router(
      title: 'Book Recommendations',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
