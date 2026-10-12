import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pertemuan_1/pertemuan_1/perubahan_1.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
