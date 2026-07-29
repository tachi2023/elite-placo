import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chantier_provider.dart';
import '../../theme/app_theme.dart';

class NouveauChantierScreen extends StatefulWidget {
  const NouveauChantierScreen({super.key});

  @override
  State<NouveauChantierScreen> createState() => _NouveauChantierScreenState();
}

class _NouveauChantierScreenState extends State<NouveauChantierScreen> {
  final _nomController = TextEditingController();
  final _villeController = TextEditingController(text: 'Douala');
  final _montantController = TextEditingController();
  String _typeTravaux = 'Plâtrerie';
  bool _enCours = false;

  static const _typesDisponibles = [
    'Plâtrerie',
    'Faux plafonds',
    'Décoration intérieure',
    'Revêtements muraux',
    'Peinture décorative',
    'Isolation',
  ];

  Future<void> _enregistrer() async {
    setState(() => _enCours = true);
    final provider = context.read<ChantierProvider>();
    final montant =
        double.tryParse(_montantController.text.replaceAll(' ', '')) ?? -1;

    final ok = await provider.creerChantier(
      nomClient: _nomController.text.trim(),
      ville: _villeController.text.trim(),
      typeTravaux: _typeTravaux,
      montantDevis: montant,
    );

    setState(() => _enCours = false);
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.derniereErreur ?? 'Erreur inconnue.'),
          backgroundColor: AppTheme.rouge,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Chantier')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Informations du Client',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: AppTheme.or),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nomController,
                label: 'Nom du client *',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _villeController,
                label: 'Ville',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 32),
              const Text(
                'Détails des Travaux',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    color: AppTheme.or),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _typeTravaux,
                dropdownColor: AppTheme.anthraciteClair,
                style:
                    const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Type de travaux *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon:
                      const Icon(Icons.handyman_outlined, color: Colors.grey),
                  filled: true,
                  fillColor: AppTheme.anthraciteClair,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.or)),
                ),
                items: _typesDisponibles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _typeTravaux = v ?? _typeTravaux),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _montantController,
                label: 'Montant du devis signé (FCFA) *',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _enCours ? null : _enregistrer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.or,
                  foregroundColor: AppTheme.anthracite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _enCours
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.anthracite))
                    : const Text(
                        'Créer le chantier',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: AppTheme.anthraciteClair,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.or)),
      ),
    );
  }
}
