import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Partage d'un export PDF par WhatsApp (réutilisé aussi pour les liens
/// de suivi client — Module 7, §10.14).
class WhatsAppShareService {
  Future<void> partagerFichier(String cheminFichier) async {
    await Share.shareXFiles(
      [XFile(cheminFichier)],
      text: 'Document PDF généré par Élite Placo & Déco',
    );
  }

  Future<void> partagerTexte(String texte) async {
    await Share.share(texte);
  }

  Future<void> partagerPdfBytes(Uint8List bytes, {String filename = 'fiche_metrage.pdf'}) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
