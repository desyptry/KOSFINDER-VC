import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kosfinder_vc/main.dart';

void main() {
  testWidgets('shows the KosFinder shell and About page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('KosFinder'), findsOneWidget);
    expect(find.textContaining('Undiksha'), findsOneWidget);

    await tester.tap(find.byKey(const Key('about-button')));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('2415051002 - Luh Desy Putri Yanti'), findsOneWidget);
  });
}
