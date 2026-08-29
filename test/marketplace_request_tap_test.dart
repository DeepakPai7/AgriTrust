import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agritrust/main.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/marketplace_screen.dart';
import 'package:agritrust/screens/buyer_request_form_screen.dart';
import 'package:agritrust/screens/product_details_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

Product _wheat() => const Product(
      id: 1,
      farmerId: 2,
      productName: 'Wheat',
      quantity: 20,
      unit: 'Quintal',
      price: 122,
      location: '21',
      farmerName: 'deepak',
    );

Future<void> _pumpMarketplace(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  AppSession.currentUser = const AuthUser(
    id: 1,
    name: 'AgriCorp India',
    email: 'buyer@example.com',
    role: 'buyer',
  );

  await tester.pumpWidget(
    ApiScope(
      service: FakeApiService(role: 'buyer', products: [_wheat()]),
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const MarketplaceScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    AppSession.currentUser = null;
  });
}

/// Regression test: the "Request to Buy" action on a marketplace product card
/// must be on-screen (hit-testable) and, when tapped, open the buyer request
/// form. Previously an oversized page header pushed the card's bottom action
/// row below the fold on common phone viewports, leaving it unreachable.
void main() {
  const sizes = <String, Size>{
    'phone-360': Size(360, 780),
    'phone-375': Size(375, 812),
    'phone-390': Size(390, 844),
    'phone-412': Size(412, 915),
    'phone-414': Size(414, 896),
    'desktop': Size(1280, 900),
  };

  for (final entry in sizes.entries) {
    testWidgets('Request to Buy reachable and opens form at ${entry.key}',
        (tester) async {
      await _pumpMarketplace(tester, entry.value);

      final button = find.text('Request to Buy').last;
      expect(button, findsWidgets);

      // The action row must be within the on-screen, tappable region.
      expect(button.hitTestable(), findsWidgets,
          reason: 'Request to Buy must be tappable on-screen at ${entry.key}');

      await tester.tap(button, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(BuyerRequestFormScreen), findsOneWidget,
          reason: 'tapping Request to Buy should open the form at ${entry.key}');
    });
  }

  testWidgets('View Details and Request to Buy are equally tappable on-screen',
      (tester) async {
    await _pumpMarketplace(tester, const Size(390, 844));

    final details = find.text('View Details').last;
    final request = find.text('Request to Buy').last;

    expect(details.hitTestable(), findsWidgets);
    expect(request.hitTestable(), findsWidgets);

    // Tapping the details button navigates to product details.
    await tester.tap(details, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailsScreen), findsOneWidget);
  });
}
