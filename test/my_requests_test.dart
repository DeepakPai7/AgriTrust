import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/my_requests_screen.dart';
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
    child: const MaterialApp(home: MyRequestsScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('My Requests renders the current buyer requests (desktop)',
      (WidgetTester tester) async {
    await _pump(tester);

    expect(find.text('My Requests'), findsOneWidget);
    // Requests for buyer id 1 in the fake.
    expect(find.text('REQ-1'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('REQ-2'), findsOneWidget);
    expect(find.text('Organic Rice'), findsOneWidget);
    expect(find.text('REQ-3'), findsOneWidget);
    expect(find.text('Soybeans'), findsOneWidget);
    expect(find.text('AgriCorp India'), findsOneWidget);
  });

  testWidgets('My Requests filters to the current buyer only',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    // Buyer 2's request (Jowar) should not appear for buyer id 1.
    await _pump(tester, service: fake);

    expect(find.text('Jowar'), findsNothing);
  });

  testWidgets('My Requests shows an empty state when the buyer has none',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    fake.requests.clear();
    await _pump(tester, service: fake);

    expect(find.text('No requests yet.'), findsOneWidget);
  });

  testWidgets('My Requests has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('My Requests'), findsOneWidget);
    expect(find.text('REQ-1'), findsOneWidget);
  });
}
