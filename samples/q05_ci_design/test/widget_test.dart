import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:q05_ci_design/main.dart' as app;

void main() {
  testWidgets('CI demo smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('CI Demo'), findsOneWidget);
  });
}
