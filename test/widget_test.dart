import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agritrust/main.dart';
import 'package:agritrust/models/models.dart';

import 'fakes.dart';

/// Drives the app from the role-selection entry point through login to the
/// farmer dashboard, returning the fake service so tests can inspect calls.
Future<FakeApiService> pumpDashboard(
  WidgetTester tester, {
  FakeApiService? service,
}) async {
  final fake = service ?? FakeApiService();
  await tester.pumpWidget(AgriTrustApp(apiService: fake));
  await tester.pumpAndSettle();

  await tester.tap(find.text('I am a Farmer'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byType(TextField).at(0));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
  await tester.ensureVisible(find.byType(TextField).at(1));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
  await tester.pumpAndSettle();
  return fake;
}

/// Drives the app from the role-selection entry point through login to the
/// buyer dashboard, returning the fake service.
Future<FakeApiService> pumpBuyerDashboard(
  WidgetTester tester, {
  FakeApiService? service,
}) async {
  final fake = service ?? FakeApiService(role: 'buyer');
  await tester.pumpWidget(AgriTrustApp(apiService: fake));
  await tester.pumpAndSettle();

  await tester.tap(find.text('I am a Buyer'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byType(TextField).at(0));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
  await tester.ensureVisible(find.byType(TextField).at(1));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
  await tester.pumpAndSettle();
  return fake;
}

/// A single deal visible to the buyer (buyer id 1) for deal-details tests.
List<Deal> _buyerDeal() => [
      Deal(
        id: 8492,
        buyerId: 1,
        farmerId: 1,
        productId: 101,
        quantity: 50,
        agreedPrice: 2400,
        status: 'confirmed',
        buyerName: 'AgriCorp India',
        farmerName: 'Ramesh Gowda',
        productName: 'Premium Wheat',
        unit: 'Qtl',
        location: 'Mysore',
        createdAt: '2023-12-10T00:00:00',
      ),
    ];

void main() {
  testWidgets('Farmer dashboard renders key sections (desktop)',
      (WidgetTester tester) async {
    // Default test surface is desktop width.
    await pumpDashboard(tester);

    expect(find.text('agritrust'), findsOneWidget);
    expect(find.text('Hello, Ravi Kumar!'), findsOneWidget);
    expect(find.text('Add Sell Record'), findsOneWidget);
    expect(find.text('Active Deals'), findsOneWidget);
    expect(find.text('Recent Buyer Requests'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('Dashboard navigates to Add Sell Record screen',
      (WidgetTester tester) async {
    await pumpDashboard(tester);

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
    await pumpDashboard(tester);
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

    await pumpDashboard(tester);

    await tester.ensureVisible(find.text('Market Prices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    expect(find.text('Market Prices'), findsWidgets);
    expect(find.text('Price Insight: Tomatoes'), findsOneWidget);
    expect(find.text('Tomato'), findsWidgets);
    expect(find.text('Onion'), findsWidgets);
    expect(find.text('Wheat'), findsWidgets);
    expect(find.text('₹2,900'), findsWidgets);
    expect(find.text('₹1,850'), findsWidgets);
    expect(find.text('₹2,400'), findsWidgets);
  });

  testWidgets('Market Prices screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpDashboard(tester);
    await tester.ensureVisible(find.text('Market Prices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    expect(find.text('Price Insight: Tomatoes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Market price cards show commodity, modal price and state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpDashboard(tester);
    await tester.ensureVisible(find.text('Market Prices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    // Each card shows the commodity name, modal price, and state region.
    expect(find.text('Tomato'), findsWidgets);
    expect(find.text('₹2,900'), findsWidgets);
    expect(find.text('Karnataka'), findsWidgets);

    expect(find.text('Onion'), findsWidgets);
    expect(find.text('₹1,850'), findsWidgets);

    // Mandi prices are expressed per quintal.
    expect(find.text('per Quintal'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard navigates to Deals screen (desktop)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpDashboard(tester);

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

    await pumpDashboard(tester);
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

    await pumpDashboard(tester);
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    expect(find.text('Deal #DC-8492'), findsOneWidget);
    expect(find.text('Financial Settlement'), findsOneWidget);
    expect(find.text('Final Net Settlement'), findsOneWidget);
    expect(find.text('Raise Dispute'), findsOneWidget);
    expect(find.text('Confirm & Pay'), findsNothing);
  });

  testWidgets('Buyer deal details shows payment and dispute options',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpBuyerDashboard(
      tester,
      service: FakeApiService(role: 'buyer', deals: _buyerDeal()),
    );
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    expect(find.text('Raise Dispute'), findsOneWidget);
    expect(find.text('Confirm & Pay'), findsOneWidget);
  });

  testWidgets('Buyer paying a deal shows the payment success screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpBuyerDashboard(
      tester,
      service: FakeApiService(role: 'buyer', deals: _buyerDeal()),
    );
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm & Pay'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Settled'), findsOneWidget);
    expect(find.text('Your payment was successful.'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('Deal card flips from In Progress to Completed after payment',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpBuyerDashboard(
      tester,
      service: FakeApiService(role: 'buyer', deals: _buyerDeal()),
    );
    await tester.ensureVisible(find.text('View Deals'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Deals'));
    await tester.pumpAndSettle();

    expect(find.text('In Progress'), findsOneWidget);

    await tester.tap(find.text('Premium Wheat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm & Pay'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('In Progress'), findsNothing);
  });

  testWidgets('Deal Details screen has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpDashboard(tester);
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

    await pumpDashboard(tester);

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

    await pumpDashboard(tester);
    await tester.ensureVisible(find.text('View All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Buyer Requests'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard Products Listed card navigates to My Products',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpDashboard(tester);

    await tester.ensureVisible(find.text('Products Listed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Products Listed'));
    await tester.pumpAndSettle();

    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Organic Rice'), findsOneWidget);
  });

  testWidgets('Accepting a buyer request calls the API', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final fake = await pumpDashboard(tester);

    await tester.ensureVisible(find.text('View All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All Requests'));
    await tester.pumpAndSettle();

    expect(fake.updatedRequestStatuses, isEmpty);
    expect(fake.createdDealRequestIds, isEmpty);
    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();

    expect(fake.updatedRequestStatuses, contains('1:accepted'));
    expect(fake.createdDealRequestIds, contains(1));

    final deal = fake.deals.last;
    expect(deal.productName, 'Premium Wheat');
    expect(deal.status, 'confirmed');

    final buyerDeals = await fake.fetchDeals(buyerId: deal.buyerId);
    expect(buyerDeals.any((d) => d.id == deal.id), isTrue);

    final farmerDeals = await fake.fetchDeals(farmerId: deal.farmerId);
    expect(farmerDeals.any((d) => d.id == deal.id), isTrue);
  });

  testWidgets('Rejecting a buyer request calls the API', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final fake = await pumpDashboard(tester);

    await tester.ensureVisible(find.text('View All Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View All Requests'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reject').first);
    await tester.pumpAndSettle();

    expect(fake.updatedRequestStatuses, contains('1:rejected'));
  });

  testWidgets('Login with valid credentials navigates to the dashboard',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    await tester.pumpWidget(AgriTrustApp(apiService: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am a Farmer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
    await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Hello, Ravi Kumar!'), findsOneWidget);
  });

  testWidgets('Login with invalid credentials shows an error snackbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(AgriTrustApp(apiService: FakeApiService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am a Farmer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'nobody@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(find.text('Hello, Ravi Kumar!'), findsNothing);
  });

  testWidgets('Buyer login navigates to the buyer dashboard',
      (WidgetTester tester) async {
    final fake = FakeApiService(role: 'buyer');
    await tester.pumpWidget(AgriTrustApp(apiService: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am a Buyer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
    await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Arjun Kumar'), findsOneWidget);
    expect(find.text('Hello, Ravi Kumar!'), findsNothing);
  });

  testWidgets('Buyer dashboard navigates to My Requests',
      (WidgetTester tester) async {
    final fake = FakeApiService(role: 'buyer');
    await tester.pumpWidget(AgriTrustApp(apiService: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am a Buyer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
    await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Arjun Kumar'), findsOneWidget);

    await tester.ensureVisible(find.text('My Requests'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Requests'));
    await tester.pumpAndSettle();

    expect(find.text('REQ-1'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
  });

  testWidgets('Buyer dashboard opens My Profile', (WidgetTester tester) async {
    final fake = FakeApiService(role: 'buyer');
    await tester.pumpWidget(AgriTrustApp(apiService: fake));
    await tester.pumpAndSettle();

    await tester.tap(find.text('I am a Buyer'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), fake.validEmail);
    await tester.enterText(find.byType(TextField).at(1), fake.validPassword);
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Arjun Kumar'), findsOneWidget);

    await tester.ensureVisible(find.text('My Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Arjun Kumar'), findsWidgets);
    expect(find.text('Company Details'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Farmer Profile tab opens the Farmer Profile screen',
      (WidgetTester tester) async {
    await pumpDashboard(tester);

    expect(find.text('Hello, Ravi Kumar!'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Farming Details'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Buyer Home tab stays on the buyer dashboard',
      (WidgetTester tester) async {
    await pumpBuyerDashboard(tester);

    expect(find.text('Welcome back, Arjun Kumar'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Arjun Kumar'), findsOneWidget);
    expect(find.text('Hello, Ravi Kumar!'), findsNothing);
  });

  testWidgets('Buyer Profile tab opens the Buyer Profile screen',
      (WidgetTester tester) async {
    await pumpBuyerDashboard(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Arjun Kumar'), findsWidgets);
    expect(find.text('Company Details'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Hello, Ravi Kumar!'), findsNothing);
  });

  testWidgets('Buyer Marketplace tab opens the Browse Produce grid',
      (WidgetTester tester) async {
    await pumpBuyerDashboard(tester);

    await tester.tap(find.text('Marketplace'));
    await tester.pumpAndSettle();

    expect(find.text('Available Produce'), findsOneWidget);
  });

  testWidgets('Farmer tab opens Market Prices (not the marketplace)',
      (WidgetTester tester) async {
    await pumpDashboard(tester);

    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    expect(find.text('Market Prices'), findsWidgets);
    expect(find.text('Available Produce'), findsNothing);
  });

  testWidgets('Buyer Browse Products quick action opens the marketplace',
      (WidgetTester tester) async {
    await pumpBuyerDashboard(tester);

    await tester.ensureVisible(find.text('Browse Products'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Browse Products'));
    await tester.pumpAndSettle();

    expect(find.text('Available Produce'), findsOneWidget);
  });

  testWidgets('Market Prices does not crash with many records (lazy + capped)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Far more records than the client cap (50) to reproduce the old crash.
    final many = List.generate(200, (i) => MarketPrice(
          commodity: 'Crop $i',
          modalPrice: 1000.0 + i,
          state: i.isEven ? 'Karnataka' : 'Maharashtra',
          arrivalDate: '29/08/2026',
        ));
    final fake = FakeApiService(marketPrices: many);
    await pumpDashboard(tester, service: fake);

    await tester.ensureVisible(find.text('Market Prices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    expect(find.text('Price Insight: Tomatoes'), findsOneWidget);
    expect(find.text('Crop 0'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Market Prices state filter narrows the list',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final fake = FakeApiService(marketPrices: [
      MarketPrice(
        commodity: 'Tomato',
        modalPrice: 2900,
        state: 'Karnataka',
        arrivalDate: '29/08/2026',
      ),
      MarketPrice(
        commodity: 'Wheat',
        modalPrice: 2400,
        state: 'Maharashtra',
        arrivalDate: '29/08/2026',
      ),
    ]);
    await pumpDashboard(tester, service: fake);

    await tester.ensureVisible(find.text('Market Prices').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Market Prices').last);
    await tester.pumpAndSettle();

    expect(find.text('Tomato'), findsWidgets);
    expect(find.text('Wheat'), findsWidgets);

    await tester.tap(find.text('All States'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maharashtra').last);
    await tester.pumpAndSettle();

    expect(find.text('Wheat'), findsWidgets);
    expect(find.text('Tomato'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
