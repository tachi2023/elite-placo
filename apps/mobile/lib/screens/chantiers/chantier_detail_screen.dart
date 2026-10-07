import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chantier_provider.dart';
import '../../repositories/chantier_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import 'ajouter_depense_screen.dart';
import 'ajouter_encaissement_screen.dart';
import 'changer_statut_dialog.dart';
import 'chantier_suivi_admin_screen.dart';
import '../metrage/fiche_metrage_screen.dart';

class ChantierDetailScreen extends StatefulWidget {
  final int chantierId;
  const ChantierDetailScreen({super.key, required this.chantierId});

  @override
  State<ChantierDetailScreen> createState() => _ChantierDetailScreenState();
}

class _ChantierDetailScreenState extends State<ChantierDetailScreen> {
  final ChantierRepository _repository = ChantierRepository();
  bool _isLoading = false;

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  Future<void> _genererAccesClient() async {
    setState(() => _isLoading = true);
    try {
      final code = await _repository.genererLienSuivi(widget.chantierId);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.anthraciteClair,
          title: const Text('Accès Client Généré',
              style: TextStyle(color: AppTheme.or)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Transmettez ce code à votre client pour le suivi sur le site web:',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              SelectableText(
                code,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.or,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              const Text('Lien web: https://elite-placo.com',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié !')));
                Navigator.pop(context);
              },
              child: const Text('Copier', style: TextStyle(color: AppTheme.or)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Fermer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getCouleurIndicateur(String? indicateur) {
    switch (indicateur) {
      case 'VERT':
        return AppTheme.vert;
      case 'ORANGE':
        return AppTheme.orange;
      case 'ROUGE':
        return AppTheme.rouge;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChantierProvider>(
      builder: (context, provider, _) {
        // Find chantier
        final chantiers =
            provider.chantiers.where((c) => c.id == widget.chantierId).toList();
        if (chantiers.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Détail du chantier')),
            body: const Center(child: Text('Chantier introuvable')),
          );
        }

        final chantier = chantiers.first;
        final situation = provider.situationDe(chantier.id!);
        final indicateurColor = _getCouleurIndicateur(situation?.indicateur);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail du chantier'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note, color: AppTheme.or),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ChangerStatutDialog(chantier: chantier),
                  );
                },
              )
            ],
          ),
          body: AppBackground(
            safeArea: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ResponsiveContent(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                AppCard(
                  accent: indicateurColor,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        chantier.nomClient,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.anthraciteClair,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.or.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        chantier.statut.replaceAll('_', ' '),
                        style: const TextStyle(
                            color: AppTheme.or,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    )
                  ],
                ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(chantier.ville ?? 'Non spécifié',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 16),
                    const Icon(Icons.handyman, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(chantier.typeTravaux ?? 'Non spécifié',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 24),

                // Carte Financière Résumé
                AppCard(
                  accent: indicateurColor,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Résultat Net',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
                            Text(
                              situation != null
                                  ? _currencyFormat
                                      .format(situation.resultatNet)
                                  : '...',
                              style: TextStyle(
                                  color: indicateurColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit'),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white12, height: 30),
                        _buildLigneFinanciere(
                            'Montant Devis',
                            situation != null ? chantier.montantDevis : 0,
                            Colors.white),
                        const SizedBox(height: 12),
                        _buildLigneFinanciere('Total Encaissé',
                            situation?.totalEncaisse ?? 0, AppTheme.or),
                        const SizedBox(height: 12),
                        _buildLigneFinanciere('Total Dépenses',
                            situation?.totalDepenses ?? 0, AppTheme.rouge),
                        const SizedBox(height: 12),
                        _buildLigneFinanciere('Reste à Encaisser',
                            situation?.resteAEncaisser ?? 0, Colors.grey),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Marge Brute',
                                style: TextStyle(color: Colors.grey)),
                            Text(
                              situation != null
                                  ? '${situation.margeBrutePourcent.toStringAsFixed(1)}%'
                                  : '...',
                              style: TextStyle(
                                  color: indicateurColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Text('Actions Rapides',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit')),
                const SizedBox(height: 16),

                // Grille d'actions
                ResponsiveGrid(
                  minTileWidth: 175,
                  children: [
                    _buildActionButton(
                        Icons.add_circle_outline, 'Encaissement', AppTheme.or,
                        () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AjouterEncaissementScreen(chantier: chantier)));
                    }),
                    _buildActionButton(
                        Icons.remove_circle_outline, 'Dépense', AppTheme.rouge,
                        () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => AjouterDepenseScreen(chantierId: chantier.id!)));
                    }),
                    _buildActionButton(
                        Icons.architecture, 'Métrage', Colors.blueAccent, () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => FicheMetrageScreen(chantierId: chantier.id!)));
                    }),
                    _buildActionButton(
                        Icons.share,
                        'Accès Client',
                        Colors.purpleAccent,
                        _isLoading ? () {} : _genererAccesClient),
                    _buildActionButton(
                        Icons.timeline_rounded,
                        'Suivi chantier',
                        AppTheme.vert,
                        () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChantierSuiviAdminScreen(
                                  chantierId: chantier.id!),
                            ))),
                  ],
                ),
              ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLigneFinanciere(String libelle, double montant, Color couleur) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(libelle, style: const TextStyle(color: Colors.grey)),
        Text(
          _currencyFormat.format(montant),
          style: TextStyle(color: couleur, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: AppTheme.anthraciteClair,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
