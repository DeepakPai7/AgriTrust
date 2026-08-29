import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agritrust/screens/give_review_screen.dart';

void main() {
  testWidgets('Give review renders sections (desktop)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GiveReviewScreen(
          buyerName: 'Rajesh Kumar',
          dealId: 'DC-8492',
          dealSummary: '50 Tons Wheat',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction Settled'), findsOneWidget);
    expect(find.text('Reviewing Buyer'), findsOneWidget);
    expect(find.text('Rajesh Kumar'), findsOneWidget);
    expect(find.text('Deal #DC-8492 • 50 Tons Wheat'), findsOneWidget);
    expect(find.text('Overall Experience'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);
    expect(find.text('Maybe Later'), findsOneWidget);
    expect(find.text('Post anonymously'), findsOneWidget);
  });

  testWidgets('Give review has no overflow on mobile',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: GiveReviewScreen(
          buyerName: 'Rajesh Kumar',
          dealId: 'DC-8492',
          dealSummary: '50 Tons Wheat',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Transaction Settled'), findsOneWidget);
    expect(find.text('Submit Review'), findsOneWidget);
  });

  testWidgets('Submitting a review shows the confirmation snackbar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GiveReviewScreen(
          buyerName: 'Rajesh Kumar',
          dealId: 'DC-8492',
          dealSummary: '50 Tons Wheat',
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Submit Review'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit Review'));
    await tester.pump();

    expect(find.text('Thank you! Review submitted.'), findsOneWidget);
  });
}
