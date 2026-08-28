import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agritrust/main.dart';

void main() {
  testWidgets('Farmer dashboard renders key sections (desktop)',
      (WidgetTester tester) async {
    // Default test surface is desktop width.
    await tester.pumpWidget(const AgriTrustApp());

    expect(find.text('DealCheck'), findsOneWidget);
    expect(find.text('Hello, Ramesh!'), findsOneWidget);
    expect(find.text('Add Sell Record'), findsOneWidget);
    expect(find.text('Active Deals'), findsOneWidget);
    expect(find.text('Recent Buyer Requests'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Dashboard navigates to Add Sell Record screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AgriTrustApp());

    await tester.tap(find.text('Add Sell Record'));
    await tester.pumpAndSettle();

    // Sub-page app bar title.
    expect(find.text('Add Sell Record'), findsOneWidget);
    expect(find.text('CROP DETAILS'), findsOneWidget);
    expect(find.text('LOGISTICS'), findsOneWidget);
    expect(find.text('CROP PHOTOS'), findsOneWidget);
    expect(find.text('ADDITIONAL DETAILS'), findsOneWidget);
    expect(find.text('List for Sale'), findsOneWidget);
  });

  testWidgets('Add Sell Record screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Use the real app so the Inter theme is applied.
    await tester.pumpWidget(const AgriTrustApp());
    await tester.tap(find.text('Add Sell Record'));
    await tester.pumpAndSettle();

    expect(find.text('List for Sale'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard navigates to Market Prices (desktop)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());

    await tester.ensureVisible(find.text('Market Prices'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices'));
    await tester.pumpAndSettle();

    expect(find.text('Market Prices'), findsWidgets);
    expect(find.text('Price Insight: Tomatoes'), findsOneWidget);
    expect(find.text('Tomato (Hybrid)'), findsOneWidget);
    expect(find.text('Onion (Red)'), findsOneWidget);
    expect(find.text('Wheat (Sona)'), findsOneWidget);
  });

  testWidgets('Market Prices screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());
    await tester.ensureVisible(find.text('Market Prices'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices'));
    await tester.pumpAndSettle();

    expect(find.text('Price Insight: Tomatoes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard navigates to Deals screen (desktop)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());

    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    expect(find.text('Active Deals'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Organic Soybeans'), findsOneWidget);
    expect(find.text('Sorghum (Jowar)'), findsOneWidget);
    expect(find.text('Deal ID: #DC-8492'), findsOneWidget);
  });

  testWidgets('Deals screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    expect(find.text('Active Deals'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deals navigates to Deal Details screen (desktop)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    expect(find.text('Deal #DC-8492-KT'), findsOneWidget);
    expect(find.text('Financial Settlement'), findsOneWidget);
    expect(find.text('Net Payable to Farmer'), findsOneWidget);
    expect(find.text('Confirm & Settle'), findsOneWidget);
    expect(find.text('Raise Dispute'), findsOneWidget);
  });

  testWidgets('Deal Details screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    expect(find.text('Financial Settlement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard navigates to Buyer Requests screen (desktop)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());

    await tester.ensureVisible(find.text('View All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Buyer Requests'), findsOneWidget);
    expect(find.text('AgriCorp India'), findsOneWidget);
    expect(find.text('Green Valley Mills'), findsOneWidget);
    expect(find.text('Sunfresh Produce'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('All Statuses'), findsNothing);
  });

  testWidgets('Buyer Requests screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgriTrustApp());
    await tester.ensureVisible(find.text('View All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Buyer Requests'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
