import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/farmer_profile_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

Widget _wrap(FakeApiService fake) {
  AppSession.currentUser = const AuthUser(
    id: 1,
    name: 'Ravi Kumar',
    email: 'ravi@gmail.com',
    role: 'farmer',
  );
  return ApiScope(
    service: fake,
    child: const MaterialApp(home: FarmerProfileScreen()),
  );
}

void main() {
  testWidgets('Farmer profile renders sections (desktop)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(FakeApiService()));
    await tester.pumpAndSettle();

    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('Verified Farmer'), findsOneWidget);
    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Farming Details'), findsOneWidget);
    expect(find.text('Farm Location'), findsOneWidget);
    expect(find.text('Payment & Settlement'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Farmer profile has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(FakeApiService()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Farmer profile is prefilled from the database',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    expect(fake.farmerProfile.name, 'Ravi Kumar');
    expect(fake.farmerProfile.crops, ['Paddy', 'Sugarcane', 'Maize']);
    expect(find.text('Paddy'), findsOneWidget);
    expect(find.text('Sugarcane'), findsOneWidget);
  });

  testWidgets('Farmer profile save persists changes via the API',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == '9876543210',
      ),
      '9812345678',
    );
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(fake.farmerProfile.phone, '9812345678');
    expect(find.text('Profile changes saved.'), findsOneWidget);
  });

  testWidgets('Farmer profile logout returns to the role switcher',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(FakeApiService()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(AppSession.currentUser, isNull);
    expect(find.text('I am a Farmer'), findsOneWidget);
    expect(find.text('I am a Buyer'), findsOneWidget);
  });
}
