import 'package:flutter_test/flutter_test.dart';
import 'package:elite_placo/providers/auth_provider.dart';

/// Vérifie le comportement du verrouillage PIN (scénario 10.1) :
/// le PIN de démonstration '1234' déverrouille, tout le reste échoue
/// et incrémente le compteur de tentatives (protection contre les essais
/// répétés — elite.md §4).
void main() {
  group('AuthProvider — verrouillage PIN', () {
    test('un PIN correct déverrouille l\u2019application', () async {
      final auth = AuthProvider();
      final ok = await auth.verifierPin('1234');

      expect(ok, isTrue);
      expect(auth.estDeverrouille, isTrue);
    });

    test('un PIN incorrect reste verrouillé et compte la tentative', () async {
      final auth = AuthProvider();
      final ok = await auth.verifierPin('0000');

      expect(ok, isFalse);
      expect(auth.estDeverrouille, isFalse);
      expect(auth.tentativesEchouees, 1);
    });

    test('verrouiller() reverrouille explicitement', () async {
      final auth = AuthProvider();
      await auth.verifierPin('1234');
      auth.verrouiller();

      expect(auth.estDeverrouille, isFalse);
    });
  });
}
