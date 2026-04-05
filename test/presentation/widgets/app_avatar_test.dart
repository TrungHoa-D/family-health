import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppAvatar', () {
    testWidgets('renders initials when imageUrl is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar(name: 'Trung Hòa', size: 50),
          ),
        ),
      );

      expect(find.text('T'), findsOneWidget);
    });

    testWidgets('renders specific sizes for factories', (WidgetTester tester) async {
      // Small
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar.small(name: 'S'),
          ),
        ),
      );
      
      final smallContainer = tester.widget<Container>(find.byType(Container).first);
      expect(smallContainer.constraints?.maxWidth, 32);

      // Large
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar.large(name: 'L'),
          ),
        ),
      );
      
      final largeContainer = tester.widget<Container>(find.byType(Container).first);
      expect(largeContainer.constraints?.maxWidth, 80);
    });

    testWidgets('renders ? when name is empty and no image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppAvatar(name: ''),
          ),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });
  });
}
