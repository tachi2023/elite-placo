import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/fiche_metrage.dart';

/// Export PDF de la fiche de métrage et des situations financières.
/// Le service génère directement des octets PDF pour rester compatible
/// avec mobile et web.
class PdfService {
  final NumberFormat _fcfa = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  Future<Uint8List> genererFicheMetrage({
    required int chantierId,
    required String systeme,
    required List<PieceMetrage> pieces,
    String? nomClient,
    String? ville,
  }) async {
    final document = pw.Document();
    final totalSurfaceNette = pieces.fold<double>(0, (total, piece) => total + piece.surfaceNette);
    final totalSurfaceBrute = pieces.fold<double>(0, (total, piece) => total + piece.surfaceBrute);
    final totalDeductions = pieces.fold<double>(0, (total, piece) => total + piece.surfaceDeduction);

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(28),
        ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Élite Placo & Déco', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('Fiche de métrage', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Chantier #$chantierId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                if (nomClient != null) pw.Text('Client : $nomClient'),
                if (ville != null) pw.Text('Ville : $ville'),
                pw.Text('Système : ${SystemePlatrerie.libelle(systeme)}'),
                pw.Text('Pièces : ${pieces.length}'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: const ['Pièce', 'L x l (m)', 'Surface brute', 'Déduction', 'Surface nette'],
            data: pieces.map((piece) {
              return [
                piece.nomPiece,
                '${piece.longueur.toStringAsFixed(2)} x ${piece.largeur.toStringAsFixed(2)}',
                piece.surfaceBrute.toStringAsFixed(2),
                piece.surfaceDeduction.toStringAsFixed(2),
                piece.surfaceNette.toStringAsFixed(2),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
            },
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Récapitulatif', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Surface brute totale : ${totalSurfaceBrute.toStringAsFixed(2)} m²'),
                pw.Text('Total des déductions : ${totalDeductions.toStringAsFixed(2)} m²'),
                pw.Text('Surface nette totale : ${totalSurfaceNette.toStringAsFixed(2)} m²'),
                pw.Text('Estimation indicative : ${_fcfa.format(totalSurfaceNette * 7500)}'),
              ],
            ),
          ),
        ],
      ),
    );

    return document.save();
  }
}
