import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elite_placo/screens/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('l onboarding affiche sa première étape', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Des chantiers'), findsOneWidget);
    expect(find.textContaining('sous contrôle'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
  });
}
