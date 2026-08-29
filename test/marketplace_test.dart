import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/marketplace_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

Future<void> _pump(WidgetTester tester, {FakeApiService? service}) async {
  final fake = service ?? FakeApiService();
  AppSession.currentUser = const AuthUser(
    id: 1,
    name: 'Arjun Kumar',
    email: 'arjun@gmail.com',
    role: 'buyer',
  );
  await tester.pumpWidget(ApiScope(
    service: fake,
    child: const MaterialApp(home: MarketplaceScreen()),
  ));
}

void main() {
  testWidgets('Marketplace renders sections from farmer products (desktop)',
      (WidgetTester tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Available Produce'), findsOneWidget);
    expect(find.text('Search crops, farmers, locations...'), findsOneWidget);
    expect(find.text('Filters'), findsOneWidget);

    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Organic Rice'), findsOneWidget);
    expect(find.text('Jowar'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('Sharma Farmer'), findsOneWidget);

    expect(find.text('View Details'), findsNWidgets(3));
    expect(find.text('Request to Buy'), findsNWidgets(3));
  });

  testWidgets('Marketplace has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Available Produce'), findsOneWidget);
  });

  testWidgets('Marketplace shows an empty state when no produce is listed',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    fake.products.clear();

    await _pump(tester, service: fake);
    await tester.pumpAndSettle();

    expect(find.text('No produce listed yet'), findsOneWidget);
    expect(find.text('View Details'), findsNothing);
  });

  testWidgets('View Details opens the product details screen',
      (WidgetTester tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Listing Details'), findsNothing);

    final detailsButton = find.text('View Details').first;
    await tester.ensureVisible(detailsButton);
    await tester.pumpAndSettle();
    await tester.tap(detailsButton);
    await tester.pumpAndSettle();

    expect(find.text('Listing Details'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsWidgets);
  });
}
