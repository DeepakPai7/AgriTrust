import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/buyer_request_form_screen.dart';
import 'package:agritrust/screens/my_requests_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

const _product = Product(
  id: 101,
  farmerId: 1,
  productName: 'Premium Wheat',
  quantity: 500,
  unit: 'Qtl',
  price: 2400,
  location: 'Mysore',
  farmerName: 'Ravi Kumar',
  createdAt: '2023-10-20T00:00:00',
);

Future<void> _pump(WidgetTester tester, {Product? product, FakeApiService? service}) async {
  final fake = service ?? FakeApiService();
  AppSession.currentUser = const AuthUser(
    id: 1,
    name: 'Arjun Kumar',
    email: 'arjun@gmail.com',
    role: 'buyer',
  );
  await tester.pumpWidget(ApiScope(
    service: fake,
    child: MaterialApp(home: BuyerRequestFormScreen(product: product)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Buyer request form renders sections (desktop)',
      (WidgetTester tester) async {
    await _pump(tester, product: _product);

    expect(find.text('Submit Request'), findsWidgets);
    expect(find.text('Selected Farmer'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsOneWidget);
    expect(find.text('Mysore'), findsOneWidget);
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Required Quantity'), findsOneWidget);
    expect(find.text('Offered Price (per unit)'), findsOneWidget);
    // Pre-filled from the product.
    expect(find.widgetWithText(TextField, '500'), findsOneWidget);
    expect(find.widgetWithText(TextField, '2400'), findsOneWidget);
  });

  testWidgets('Buyer request form has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await _pump(tester, product: _product);

    expect(tester.takeException(), isNull);
    expect(find.text('Submit Request'), findsWidgets);
  });

  testWidgets('Submitting a request creates it and opens My Requests',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    await _pump(tester, product: _product, service: fake);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Submit Request'));
    await tester.tap(find.widgetWithText(FilledButton, 'Submit Request'));
    await tester.pumpAndSettle();

    expect(fake.requests.any((r) => r.productName == 'Premium Wheat'), isTrue);
    expect(find.byType(MyRequestsScreen), findsOneWidget);
  });
}
