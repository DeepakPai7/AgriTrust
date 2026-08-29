import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/models/models.dart';
import 'package:agritrust/screens/product_details_screen.dart';

/// A tiny valid 1x1 PNG so [_decodePhoto] yields bytes for the image test.
final String _tinyPngBase64 = base64Encode([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

Product _product({String? photo, String? notes}) => Product(
      id: 101,
      farmerId: 1,
      productName: 'Premium Wheat',
      quantity: 500,
      unit: 'Qtl',
      price: 2400,
      location: 'Mysore',
      notes: notes,
      photo: photo,
      createdAt: '2023-10-20T00:00:00',
      farmerName: 'Ravi Kumar',
    );

void main() {
  testWidgets('Product details renders real product data (desktop)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailsScreen(product: _product(photo: _tinyPngBase64)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Listing Details'), findsOneWidget);
    expect(find.text('Premium Wheat'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('Mysore'), findsWidgets);
    expect(find.text('ID: PRD-101'), findsOneWidget);
    expect(find.text('Consignment Details'), findsOneWidget);
    expect(find.text('500 Qtl'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Product details shows placeholder and notes fallback',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductDetailsScreen(product: Product(
          id: 102,
          farmerId: 1,
          productName: 'Organic Rice',
          quantity: 300,
          unit: 'Qtl',
          price: 3300,
          location: 'Mysore',
          createdAt: '2023-10-21T00:00:00',
          farmerName: 'Ravi Kumar',
        )),
      ),
    );
    await tester.pumpAndSettle();

    // No photo -> fallback gradient placeholder, no Image widget.
    expect(find.byType(Image), findsNothing);
    expect(find.text('Organic Rice'), findsOneWidget);
    expect(find.text('Farmer'), findsNothing);
    expect(find.text('Ravi Kumar'), findsWidgets);
  });

  testWidgets('Product details has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailsScreen(product: _product()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Listing Details'), findsOneWidget);
    // Mobile shows the fixed bottom action bar.
    expect(find.text('Create Buyer Request'), findsOneWidget);
  });
}
