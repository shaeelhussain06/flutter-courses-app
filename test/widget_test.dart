import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Flutter authentication app smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FlutterAuthApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}