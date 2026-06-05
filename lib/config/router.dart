import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/connectivity_provider.dart';
import '../screens/book_detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/recommendations_screen.dart';
import '../screens/book_list_screen.dart';

/// Navigation Router Configuration — Reference Implementation
///
/// This file configures go_router with a [StatefulShellRoute] to provide
/// bottom-tab navigation with independent navigation stacks per tab.
///
/// ## ShellRoute Pattern
/// A ShellRoute wraps matched child routes in a shared "shell" widget (e.g.,
/// a Scaffold with a BottomNavigationBar). All child routes render inside
/// the shell, so the bottom nav persists across screens.
///
/// ## StatefulShellRoute for Tab State
/// Unlike a basic ShellRoute, [StatefulShellRoute] preserves the navigation
/// state of each tab independently. Each tab gets its own Navigator via
/// [StatefulShellBranch], so navigating within one tab does not affect
/// the back-stack of other tabs. This means a user can drill into a book
/// detail in the Books tab, switch to Favorites, and return to Books with
/// the detail screen still showing.
///
/// ## Route Structure
/// /books              → Book List (home tab)
/// /books/:id          → Book Detail within Books tab
/// /favorites          → Favorites tab
/// /favorites/:id      → Book Detail within Favorites tab
/// /recommendations    → Recommendations tab
/// /recommendations/:id → Book Detail within Recommendations tab

// Navigator keys for each branch — required by StatefulShellBranch to
// maintain separate navigation stacks per tab.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _booksNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'books');
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'favorites');
final _recommendationsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'recommendations');

/// The application's router configuration.
///
/// Uses [GoRouter] with a [StatefulShellRoute.indexedStack] to render
/// a bottom navigation bar shell around the three main tabs. The default
/// route redirects to `/books` (the Book List tab).
final GoRouter router = GoRouter(
  // The root navigator key allows routes outside the shell (e.g., modals)
  // to use the root navigator instead of a branch navigator.
  navigatorKey: _rootNavigatorKey,

  // Default route — when the app launches, navigate to the Books tab.
  initialLocation: '/books',

  routes: [
    // StatefulShellRoute.indexedStack creates a shell that uses an IndexedStack
    // to keep all branch widgets alive, preserving scroll position and state.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // The shell widget wraps all tab content with a bottom navigation bar.
        return ScaffoldWithBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        // ─── Books Tab (index 0) ───────────────────────────────────────
        // Each StatefulShellBranch gets its own navigator key so it maintains
        // an independent back-stack. Navigating to /books/:id pushes onto
        // this branch's stack without affecting other tabs.
        StatefulShellBranch(
          navigatorKey: _booksNavigatorKey,
          routes: [
            GoRoute(
              path: '/books',
              builder: (context, state) => const BookListScreen(),
              routes: [
                // Route parameters: `:id` captures the book ID from the URL.
                // Access it via state.pathParameters['id'] in the builder.
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final bookId = state.pathParameters['id']!;
                    return BookDetailScreen(bookId: bookId);
                  },
                ),
              ],
            ),
          ],
        ),

        // ─── Favorites Tab (index 1) ──────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _favoritesNavigatorKey,
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final bookId = state.pathParameters['id']!;
                    return BookDetailScreen(bookId: bookId);
                  },
                ),
              ],
            ),
          ],
        ),

        // ─── Recommendations Tab (index 2) ────────────────────────────
        StatefulShellBranch(
          navigatorKey: _recommendationsNavigatorKey,
          routes: [
            GoRoute(
              path: '/recommendations',
              builder: (context, state) => const RecommendationsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final bookId = state.pathParameters['id']!;
                    return BookDetailScreen(bookId: bookId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],

  // Redirect guards — currently no auth-based redirects are needed since
  // this is a local-first app. If you add user authentication later, add
  // a redirect here to send unauthenticated users to a login screen:
  //
  // redirect: (context, state) {
  //   final isLoggedIn = /* check auth state */;
  //   if (!isLoggedIn && state.matchedLocation != '/login') return '/login';
  //   return null; // no redirect
  // },
);

/// Shell widget that provides a Material Design 3 [NavigationBar] (bottom nav)
/// around the currently active tab content.
///
/// The [navigationShell] parameter comes from [StatefulShellRoute] and manages
/// which branch's widget tree is currently visible. Calling
/// `navigationShell.goBranch(index)` switches tabs while preserving each
/// tab's navigation state.
///
/// When the Supabase connection fails on startup, this widget displays a
/// persistent [MaterialBanner] at the top of the scaffold warning the user
/// that the app is running with offline mock data. The banner can be dismissed.
class ScaffoldWithBottomNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  /// The navigation shell provided by [StatefulShellRoute].
  /// It contains the current branch's widget and handles tab switching.
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState
    extends ConsumerState<ScaffoldWithBottomNavBar> {
  /// Whether the connectivity warning banner has been dismissed by the user.
  bool _bannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final supabaseFailed = ref.watch(supabaseConnectionFailedProvider);

    // Show a persistent MaterialBanner when Supabase was attempted but failed.
    // The banner remains visible until the user dismisses it.
    final showBanner = supabaseFailed && !_bannerDismissed;

    return Scaffold(
      body: Column(
        children: [
          if (showBanner)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.cloud_off, color: Colors.orange),
              content: const Text(
                'Unable to connect to the server. '
                'Running with offline mock data.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _bannerDismissed = true;
                    });
                  },
                  child: const Text('DISMISS'),
                ),
              ],
            ),
          Expanded(child: widget.navigationShell),
        ],
      ),
      // Material Design 3 NavigationBar — the modern replacement for
      // the older BottomNavigationBar widget. It supports adaptive layouts,
      // label behavior, and integrates with the M3 color system.
      bottomNavigationBar: NavigationBar(
        // The currently selected tab index, driven by the shell route state.
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // goBranch navigates to the specified branch index.
          // Setting initialLocation: true returns the tab to its root route
          // if the user taps the already-selected tab (common UX pattern).
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Books',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Recommendations',
          ),
        ],
      ),
    );
  }
}

// ─── End of Router Configuration ─────────────────────────────────────────────
