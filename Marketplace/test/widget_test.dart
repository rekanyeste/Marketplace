// Smoke tests for pure-logic widgets and utilities that don't need Firebase.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearbuy/core/widgets/empty_state.dart';
import 'package:nearbuy/core/widgets/glass_card.dart';

void main() {
  group('EmptyState widget', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              subtitle: 'Try different keywords',
            ),
          ),
        ),
      );

      expect(find.text('No results'), findsOneWidget);
      expect(find.text('Try different keywords'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('renders with empty subtitle string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Empty',
              subtitle: '',
            ),
          ),
        ),
      );

      expect(find.text('Empty'), findsOneWidget);
    });
  });

  group('GlassCard widget', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Hello glass'),
            ),
          ),
        ),
      );

      expect(find.text('Hello glass'), findsOneWidget);
    });

    testWidgets('renders with custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              padding: EdgeInsets.all(24),
              child: Text('padded'),
            ),
          ),
        ),
      );

      expect(find.text('padded'), findsOneWidget);
    });
  });
}
