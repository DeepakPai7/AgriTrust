import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/add_sell_record_screen.dart';
import 'package:agritrust/services/api_scope.dart';
import 'package:agritrust/services/session.dart';

import 'fakes.dart';

void main() {
  testWidgets('Add Sell Record submits a product to the service',
      (WidgetTester tester) async {
    final fake = FakeApiService();
    AppSession.currentUser = const AuthUser(
      id: 7,
      name: 'Ravi Kumar',
      email: 'ravi@gmail.com',
      role: 'farmer',
    );

    await tester.pumpWidget(
      ApiScope(
        service: fake,
        child: const MaterialApp(home: AddSellRecordScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Crop dropdown (index 0).
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wheat').last);
    await tester.pumpAndSettle();

    // Unit dropdown (index 1).
    await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quintal').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '50');
    await tester.enterText(find.byType(TextField).at(1), '2400');
    await tester.enterText(find.byType(TextField).at(3), 'Mysore Farm');
    await tester.enterText(find.byType(TextField).at(4), 'Fresh stock');

    await tester.pumpAndSettle();

    // Open the date picker from the date field (index 2) and pick today.
    final dateField = find.byType(TextField).at(2);
    await tester.ensureVisible(dateField);
    await tester.pumpAndSettle();
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('List for Sale'));
    await tester.pumpAndSettle();

    expect(fake.createdProducts, hasLength(1));
    final created = fake.createdProducts.single;
    expect(created['farmer_id'], 7);
    expect(created['product_name'], 'Wheat');
    expect(created['quantity'], 50.0);
    expect(created['unit'], 'Quintal');
    expect(created['price'], 2400.0);
    expect(created['location'], 'Mysore Farm');
    expect(created['notes'], 'Fresh stock');
    expect(created['created_at'], isNotNull);

    // The screen pops (closes back bar) after success.
    await tester.pumpAndSettle();
    expect(find.text('List for Sale'), findsNothing);
  });
}
