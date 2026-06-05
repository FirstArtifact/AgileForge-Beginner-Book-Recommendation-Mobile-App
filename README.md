# Book Recommendation App — Teaching Shell

A Flutter mobile application for book recommendations, built as a **teaching shell**. The UI, navigation, and mock data layer are fully implemented as working references. The business logic services (favorites, preferences, recommendations) and external integrations (Open Library API, Supabase) are scaffolded as stubs with inline TODO guidance — **6 exercises** for learners to complete.

## Prerequisites

- **Flutter SDK** 3.x+ ([install guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK** (bundled with Flutter)
- **Supabase account** (free tier) — only needed when implementing the Supabase exercise
- An iOS simulator, Android emulator, or physical device for running the app

## Getting Started

```bash
# 1. Clone the repository
git clone <repo-url>
cd AgileForge-Beginner-Book-Recommendation-Mobile-App

# 2. Install dependencies
flutter pub get

# 3. Run the app (works immediately with mock data — no API keys needed)
flutter run
```

The app launches with `MockDataService` by default, providing 15+ sample books across 5 genres. No network connection or API keys are required for the reference implementation to function.

## Environment Variables

When you are ready to implement the Supabase exercise, pass credentials via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

| Variable | Description | Where to find |
|----------|-------------|---------------|
| `SUPABASE_URL` | Your Supabase project URL | Dashboard → Settings → API → Project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous/public key | Dashboard → Settings → API → anon / public |

To enable real API calls, also set `useRealApi: true` in `lib/config/app_config.dart`.

## Project Structure

```
lib/
├── config/             # App configuration and routing
│   ├── app_config.dart       # useRealApi flag and global settings
│   ├── router.dart           # go_router with StatefulShellRoute navigation
│   └── supabase_config.dart  # Supabase credentials from environment
├── models/             # Data model classes with JSON serialization
│   ├── book.dart             # Book model (id, title, author, genre, etc.)
│   ├── genre.dart            # Genre class
│   └── user_preferences.dart # User preferences model
├── providers/          # Riverpod state management providers
│   ├── book_providers.dart         # Book list, genre filter, data source
│   ├── connectivity_provider.dart  # Connection state tracking
│   ├── favorites_provider.dart     # Favorites state with optimistic updates
│   ├── preferences_provider.dart   # User preferences provider
│   └── recommendations_provider.dart # Recommendation generation
├── screens/            # Presentation layer (UI screens)
│   ├── book_list_screen.dart       # Home tab — book list with genre chips
│   ├── book_detail_screen.dart     # Book detail with favorite toggle
│   ├── favorites_screen.dart       # Favorites tab
│   └── recommendations_screen.dart # Recommendations tab
├── services/           # Business logic and data access
│   ├── book_data_source.dart       # BookDataSource interface (abstract)
│   ├── book_repository.dart        # Data source selector/coordinator
│   ├── mock_data_service.dart      # Reference implementation (mock data)
│   ├── api_service_stub.dart       # Scaffolded stub (Open Library API)
│   ├── supabase_service.dart       # Scaffolded stub (Supabase backend)
│   ├── favorites_service.dart      # Favorites persistence (shared_preferences)
│   ├── preferences_service.dart    # Genre preference persistence
│   └── recommendation_service.dart # Genre-based recommendation engine
├── utils/              # Utility functions
│   └── text_utils.dart             # Text truncation helpers
├── widgets/            # Reusable widget components
└── main.dart           # App entry point and initialization
```

## Feature Status

| Feature | Status | Key Files |
|---------|--------|-----------|
| Book List Display | Reference Implementation | `screens/book_list_screen.dart`, `providers/book_providers.dart` |
| Genre Filtering | Reference Implementation | `screens/book_list_screen.dart`, `providers/book_providers.dart` |
| Book Detail View | Reference Implementation | `screens/book_detail_screen.dart` |
| Navigation (go_router) | Reference Implementation | `config/router.dart` |
| Mock Data Service | Reference Implementation | `services/mock_data_service.dart` |
| User Preference Persistence | Scaffolded Stub | `services/preferences_service.dart` |
| Favorites Persistence | Scaffolded Stub | `services/favorites_service.dart` |
| Favorites State (Optimistic Updates) | Scaffolded Stub | `providers/favorites_provider.dart` |
| Genre-Based Recommendations | Scaffolded Stub | `services/recommendation_service.dart` |
| Open Library API Integration | Scaffolded Stub | `services/api_service_stub.dart` |
| Supabase Backend Integration | Scaffolded Stub | `services/supabase_service.dart`, `config/supabase_config.dart` |

## Learning Exercises

This app has **6 scaffolded exercises** ordered by increasing complexity. See `LEARNING_GUIDE.md` for detailed step-by-step instructions, code hints, and success criteria for each exercise.

| # | Exercise | Difficulty | Stub File |
|---|----------|-----------|-----------|
| 1 | Genre Preference Persistence | ⭐ Beginner | `services/preferences_service.dart` |
| 2 | Favorites Persistence | ⭐⭐ Intermediate | `services/favorites_service.dart` |
| 3 | Optimistic Updates with Rollback | ⭐⭐ Intermediate | `providers/favorites_provider.dart` |
| 4 | Recommendation Algorithm | ⭐⭐⭐ Advanced | `services/recommendation_service.dart` |
| 5 | Open Library API Integration | ⭐⭐⭐ Advanced | `services/api_service_stub.dart` |
| 6 | Supabase Backend | ⭐⭐⭐ Advanced | `services/supabase_service.dart` |

**The app runs out of the box** — exercises add real functionality on top of the working shell. Start with Exercise 1 and work your way up.

## Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/unit/services/mock_data_service_test.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture

The app follows a layered architecture:

1. **Presentation** — Flutter widgets (screens) that consume Riverpod providers
2. **State** — Riverpod providers managing application state and reactivity
3. **Data** — Service classes implementing typed interfaces (`BookDataSource`, etc.)
4. **Data Sources** — Concrete implementations (mock, API stub, Supabase stub, shared_preferences)

Navigation uses `go_router` with `StatefulShellRoute` for bottom-tab navigation that preserves per-tab back stacks independently.

## License

This project is provided as educational material.
