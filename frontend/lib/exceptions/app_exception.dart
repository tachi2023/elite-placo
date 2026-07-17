/// Exception métier levée par les services quand une règle du cahier des
/// charges n'est pas respectée (ex. montant négatif, champ obligatoire
/// manquant, limite de 30 pièces dépassée...). Le message est déjà rédigé
/// en français, prêt à être affiché tel quel dans un SnackBar/dialogue —
/// voir masterclass : "un contrôle explique ce qui s'est passé, jamais
/// une erreur vague".
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
