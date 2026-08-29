import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/buyer_profile_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

Widget _wrap(FakeApiService fake) {
  AppSession.currentUser = const AuthUser(
    id: 1,
    name: 'Arjun Kumar',
    email: 'arjun@gmail.com',
    role: 'buyer',
  );
  return ApiScope(
    service: fake,
    child: const MaterialApp(home: BuyerProfileScreen()),
  );
}

void main() {
  testWidgets('Buyer profile renders sections (desktop)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(FakeApiService(role: 'buyer')));
    await tester.pumpAndSettle();

    expect(find.text('Arjun Kumar'), findsWidgets);
    expect(find.text('GreenEarth Organics'), findsWidgets);
    expect(find.text('Verified Buyer'), findsOneWidget);
    expect(find.text('Company Details'), findsOneWidget);
    expect(find.text('Purchasing Interests'), findsOneWidget);
    expect(find.text('Contact Information'), findsOneWidget);
    expect(find.text('Payment & Settlement'), findsOneWidget);
    expect(find.text('Business Documents'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Buyer profile has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(FakeApiService(role: 'buyer')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Arjun Kumar'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);
  });

  testWidgets('Buyer profile save persists changes via the API',
      (WidgetTester tester) async {
    final fake = FakeApiService(role: 'buyer');
    await tester.pumpWidget(_wrap(fake));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == '9876543210',
      ),
      '9876500000',
    );
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(fake.buyerProfile.contactPhone, '9876500000');
    expect(find.text('Profile changes saved.'), findsOneWidget);
  });

  testWidgets('Buyer profile logout returns to the role switcher',
      (WidgetTester tester) async {
    await tester.pumpWidget(_wrap(FakeApiService(role: 'buyer')));
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
