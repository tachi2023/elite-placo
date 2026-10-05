import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../dashboard/tableau_de_bord_screen.dart';
import 'pin_lock_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifiant = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _chargement = false;
  bool _visible = false;

  @override
  void dispose() {
    _identifiant.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _connexion() async {
    if (_identifiant.text.trim().isEmpty || _motDePasse.text.isEmpty) return;
    setState(() => _chargement = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.seConnecter(_identifiant.text, _motDePasse.text);
    if (!mounted) return;
    setState(() => _chargement = false);
    if (!ok) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => auth.isPinConfigured ? const TableauDeBordScreen() : const PinLockScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().erreurConnexion;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF29261F), AppTheme.anthracite, Color(0xFF080808)])),
        child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Icon(Icons.architecture_rounded, color: AppTheme.or, size: 52),
                const SizedBox(height: 18),
                Text('Espace administrateur', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text('Connectez-vous pour gérer vos chantiers et votre site.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grisFonce)),
                const SizedBox(height: 28),
                TextField(controller: _identifiant, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Identifiant', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 14),
                TextField(controller: _motDePasse, obscureText: !_visible, onSubmitted: (_) => _connexion(), decoration: InputDecoration(labelText: 'Mot de passe', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _visible = !_visible), icon: Icon(_visible ? Icons.visibility_off : Icons.visibility)))),
                if (error != null) ...[const SizedBox(height: 14), Text(error, style: const TextStyle(color: AppTheme.erreur))],
                const SizedBox(height: 24),
                FilledButton.icon(onPressed: _chargement ? null : _connexion, icon: _chargement ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login), label: Text(_chargement ? 'Connexion...' : 'Se connecter')),
              ]),
            ),
          ),
        )))),
      ),
    );
  }
}
