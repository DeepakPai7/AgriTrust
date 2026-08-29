import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/screens/buyer_dashboard_screen.dart';

void main() {
  testWidgets('Buyer dashboard renders sections (desktop)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BuyerDashboardScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, Buyer'), findsOneWidget);
    expect(find.text('Active Requests'), findsOneWidget);
    expect(find.text('Active Deals'), findsWidgets);
    expect(find.text('Pending Actions'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Browse Products'), findsOneWidget);
    expect(find.text('Create Request'), findsOneWidget);
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('View All Activity'), findsOneWidget);
    expect(find.text('Market Insights'), findsOneWidget);
  });

  testWidgets('Buyer dashboard has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: BuyerDashboardScreen()),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Welcome back, Buyer'), findsOneWidget);
  });
}
