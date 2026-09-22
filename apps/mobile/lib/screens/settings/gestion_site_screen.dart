import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GestionSiteScreen extends StatefulWidget {
  const GestionSiteScreen({super.key});

  @override
  State<GestionSiteScreen> createState() => _GestionSiteScreenState();
}

class _GestionSiteScreenState extends State<GestionSiteScreen> {
  // Simuler des données pour l'UI
  final List<Map<String, String>> services = [
    {'titre': 'Faux Plafonds', 'cle': 'service_1'},
    {'titre': 'Cloisons & Doublages', 'cle': 'service_2'},
    {'titre': 'Décoration & Staff', 'cle': 'service_3'},
  ];

  final List<Map<String, String>> realisations = [
    {'titre': 'Villa Moderne - Yaoundé', 'cle': 'realisation_1'},
    {'titre': 'Bureaux Corporate - Douala', 'cle': 'realisation_2'},
    {'titre': 'Hôtel de Luxe - Kribi', 'cle': 'realisation_3'},
    {'titre': 'Résidence Privée - Bafoussam', 'cle': 'realisation_4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gestion du Site Web',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.or),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E24),
              AppTheme.anthracite,
              Color(0xFF0F0F12),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionHeader('Services Proposés', Icons.handyman),
              const SizedBox(height: 16),
              ...services.map((s) => _buildItemCard(s['titre']!)),
              const SizedBox(height: 32),
              _buildSectionHeader('Photos Réalisations', Icons.photo_library),
              const SizedBox(height: 16),
              ...realisations
                  .map((r) => _buildItemCard(r['titre']!, hasImage: true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.or, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.blanc,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildItemCard(String title, {bool hasImage = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: hasImage
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.or.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.or.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.image, color: AppTheme.or),
              )
            : const Icon(Icons.text_snippet, color: AppTheme.grisClair),
        title: Text(
          title,
          style: const TextStyle(
              color: AppTheme.blanc, fontWeight: FontWeight.w600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: AppTheme.or),
          onPressed: () {
            // Action de modification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Modification de "$title"'),
                backgroundColor: AppTheme.anthraciteClair,
              ),
            );
          },
        ),
      ),
    );
  }
}
