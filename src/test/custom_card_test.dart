import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:api2025/ui/widgets/custom_card.dart';

void main() {
  group('CustomCard trailing vs arrow behavior', () {
    testWidgets('shows arrow when trailing is null and showArrow=true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              iconData: Icons.event,
              title: 'Titulo',
              subtitle: 'Subtitulo',
              onTap: () {},
              showArrow: true,
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });

    testWidgets('hides arrow when trailing is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomCard(
              iconData: Icons.event,
              title: 'Titulo',
              subtitle: 'Subtitulo',
              onTap: () {},
              trailing: const Icon(Icons.delete),
              showArrow: true, // should be ignored because trailing is set
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });
}