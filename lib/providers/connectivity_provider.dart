/// Connectivity state provider for Supabase connection status.
///
/// This provider tracks whether the app attempted a Supabase connection
/// that failed, enabling the UI to show a MaterialBanner warning.
/// When credentials are placeholder values (default), no connection is
/// attempted and no warning is shown.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the Supabase connection was attempted but failed.
///
/// - `false` (default): No failure — either Supabase connected successfully
///   or was never attempted (placeholder credentials / useRealApi = false).
/// - `true`: Supabase initialization was attempted with real credentials
///   but failed (timeout or error). The app fell back to MockDataService.
///
/// The UI watches this provider to decide whether to show a persistent
/// MaterialBanner connectivity warning at the top of the scaffold.
final supabaseConnectionFailedProvider = StateProvider<bool>((ref) => false);
