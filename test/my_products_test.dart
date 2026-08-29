import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/my_products_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

void main() {
  testWidgets('My Products renders only the current farmer products',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    AppSession.currentUser = const AuthUser(
      id: 1,
      name: 'Ravi Kumar',
      email: 'ravi@gmail.com',
      role: 'farmer',
    );

    await tester.pumpWidget(
      ApiScope(
        service: fake,
        child: const MaterialApp(home: MyProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Organic Rice'), findsOneWidget);
    // Farmer 2's product should not be listed.
    expect(find.text('Jowar'), findsNothing);
  });

  testWidgets('View Requests opens buyer requests filtered to this farmer',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    AppSession.currentUser = const AuthUser(
      id: 1,
      name: 'Ravi Kumar',
      email: 'ravi@gmail.com',
      role: 'farmer',
    );

    await tester.pumpWidget(
      ApiScope(
        service: fake,
        child: const MaterialApp(home: MyProductsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Requests').first);
    await tester.pumpAndSettle();

    expect(find.text('Buyer Requests'), findsOneWidget);
    // Only farmer 1's requests show; farmer 2's (Harvest Foods) does not.
    expect(find.textContaining('AgriCorp India'), findsOneWidget);
    expect(find.text('Harvest Foods'), findsNothing);
  });
}
