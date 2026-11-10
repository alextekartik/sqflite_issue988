import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_issue988/main.dart';

void main() {
  testWidgets('Home buttons smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame (no database is opened before a tap).
    await tester.pumpWidget(const MyApp());

    for (var text in [
      'Open DB',
      'Long update query',
      'Short select query',
      'Delete DB',
    ]) {
      expect(find.widgetWithText(ElevatedButton, text), findsOneWidget);
    }
  });
}
