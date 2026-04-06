// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:urkufood/app/app.dart';
import 'package:urkufood/app/app_controller.dart';

void main() {
  testWidgets('La app muestra el splash inicial', (WidgetTester tester) async {
    await tester.pumpWidget(UrkuFoodApp(controller: AppController()));

    expect(find.text('La Carta'), findsOneWidget);
    expect(find.text('URKU Food experience'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
