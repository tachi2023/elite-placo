import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../services/whatsapp_share_service.dart';
import '../../theme/app_theme.dart';

class DemandesDevisScreen extends StatefulWidget {
  const DemandesDevisScreen({super.key});

  @override
  State<DemandesDevisScreen> createState() => _DemandesDevisScreenState();
}

class _DemandesDevisScreenState extends State<DemandesDevisScreen> {
  final _api = ApiService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _filter = 'TOUS';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final response = await _api.client.get('/api/devis');
      _items = (response.data as List<dynamic>).map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de charger les demandes de devis.')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _status(Map<String, dynamic> item, String status) async {
    await _api.client.patch('/api/devis/${item['id']}/statut', queryParameters: {'statut': status});
    await _load();
  }

  List<Map<String, dynamic>> get _filtered => _filter == 'TOUS' ? _items : _items.where((item) => item['statut'] == _filter).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Demandes de devis'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.or))
        : Column(children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: ['TOUS', 'NOUVELLE', 'CONTACTEE', 'DEVIS_ENVOYE', 'GAGNEE', 'PERDUE']
                    .map(
                      (value) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: ChoiceChip(
                          label: Text(value.replaceAll('_', ' ')),
                          selected: _filter == value,
                          selectedColor: AppTheme.or,
                          onSelected: (_) => setState(() => _filter = value),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(child: _filtered.isEmpty ? const Center(child: Text('Aucune demande dans ce filtre.')) : RefreshIndicator(color: AppTheme.or, onRefresh: _load, child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _filtered.length, itemBuilder: (context, index) => _card(_filtered[index])))),
          ]),
  );

  Widget _card(Map<String, dynamic> item) {
    final phone = item['telephone']?.toString() ?? '';
    final name = item['nom']?.toString() ?? 'Client';
    return Card(child: ExpansionTile(
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${item['typeTravaux'] ?? ''} · ${item['statut'] ?? ''}'),
      leading: const CircleAvatar(backgroundColor: AppTheme.or, child: Icon(Icons.request_quote, color: AppTheme.anthracite)),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      children: [
        Align(alignment: Alignment.centerLeft, child: Text('Ville : ${item['ville'] ?? '-'}\nSurface : ${item['superficie'] ?? '-'}\nBudget : ${item['budgetEstime'] ?? '-'}\n${item['message'] ?? ''}')),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          OutlinedButton.icon(onPressed: phone.isEmpty ? null : () => launchUrl(Uri.parse('tel:$phone')), icon: const Icon(Icons.call), label: const Text('Appeler')),
          OutlinedButton.icon(onPressed: phone.isEmpty ? null : () => WhatsAppShareService().partagerTexte('Bonjour $name, Élite Placo & Déco revient vers vous concernant votre demande de devis.'), icon: const Icon(Icons.chat), label: const Text('WhatsApp')),
          PopupMenuButton<String>(onSelected: (value) => _status(item, value), itemBuilder: (_) => const [PopupMenuItem(value: 'NOUVELLE', child: Text('Nouvelle')), PopupMenuItem(value: 'CONTACTEE', child: Text('Contactée')), PopupMenuItem(value: 'DEVIS_ENVOYE', child: Text('Devis envoyé')), PopupMenuItem(value: 'GAGNEE', child: Text('Gagnée')), PopupMenuItem(value: 'PERDUE', child: Text('Perdue'))], child: const Chip(label: Text('Changer le statut'))),
        ]),
      ],
    ));
  }
}
