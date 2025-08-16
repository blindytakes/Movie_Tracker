import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker/main.dart';

void main() {
  testWidgets('App launches and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the login screen is displayed
    expect(find.text('Movie Tracker'), findsOneWidget);
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets); // Email and password fields
  });
}