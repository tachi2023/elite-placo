import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ChangerMotDePasseScreen extends StatefulWidget {
  const ChangerMotDePasseScreen({super.key});

  @override
  State<ChangerMotDePasseScreen> createState() => _ChangerMotDePasseScreenState();
}

class _ChangerMotDePasseScreenState extends State<ChangerMotDePasseScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _old.dispose(); _new.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_new.text.length < 12 || _new.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nouveau mot de passe doit avoir 12 caractères minimum et être confirmé.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService().client.post('/api/auth/change-password', data: {'ancienMotDePasse': _old.text, 'nouveauMotDePasse': _new.text});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mot de passe modifié.')));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ancien mot de passe incorrect ou requête refusée.')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Changer le mot de passe')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Le mot de passe ne sera jamais enregistré dans l’application.', style: TextStyle(color: AppTheme.grisClair)),
      const SizedBox(height: 24),
      TextField(controller: _old, obscureText: true, decoration: const InputDecoration(labelText: 'Ancien mot de passe')),
      const SizedBox(height: 12),
      TextField(controller: _new, obscureText: true, decoration: const InputDecoration(labelText: 'Nouveau mot de passe (12 caractères minimum)')),
      const SizedBox(height: 12),
      TextField(controller: _confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmer le nouveau mot de passe')),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: _loading ? null : _submit, icon: const Icon(Icons.lock_reset), label: Text(_loading ? 'Modification...' : 'Modifier le mot de passe')),
    ]),
  );
}
