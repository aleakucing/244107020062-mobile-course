// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('Navigation smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that Home page is loaded and Item 1 is displayed.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);

    // Tap Item 1 and settle transition.
    await tester.tap(find.text('Item 1'));
    await tester.pumpAndSettle();

    // Verify that Detail page is displayed with dynamic ID.
    expect(find.text('Detail 1'), findsOneWidget);
    expect(find.text('Anda membuka item dengan id: 1'), findsOneWidget);
  });
}
