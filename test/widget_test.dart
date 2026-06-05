import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_recommendation_app/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BookRecommendationApp(),
      ),
    );

    // The app should render the bottom navigation bar with tab labels.
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Recommendations'), findsOneWidget);
  });
}
