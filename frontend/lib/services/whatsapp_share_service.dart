import 'package:share_plus/share_plus.dart';

/// Partage d'un export PDF par WhatsApp (réutilisé aussi pour les liens
/// de suivi client — Module 7, §10.14).
class WhatsAppShareService {
  Future<void> partagerFichier(String cheminFichier) async {
    await Share.shareXFiles([XFile(cheminFichier)]);
  }

  Future<void> partagerTexte(String texte) async {
    await Share.share(texte);
  }
}
