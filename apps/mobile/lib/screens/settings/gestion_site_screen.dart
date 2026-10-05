import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/site_content.dart';
import '../../repositories/site_content_repository.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class GestionSiteScreen extends StatefulWidget {
  const GestionSiteScreen({super.key});

  @override
  State<GestionSiteScreen> createState() => _GestionSiteScreenState();
}

class _GestionSiteScreenState extends State<GestionSiteScreen>
    with SingleTickerProviderStateMixin {
  static const _types = <String>[
    'SERVICE', 'REALISATIONS', 'PROJET', 'A_PROPOS', 'PARAMETRE_GLOBAL'
  ];
  static const _labels = <String>[
    'Services', 'Réalisations', 'Projets', 'À propos', 'Coordonnées'
  ];

  final SiteContentRepository _repository = SiteContentRepository();
  final ImagePicker _picker = ImagePicker();
  late final TabController _tabs;
  final Map<String, List<SiteContent>> _items = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _types.length, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) _load(_types[_tabs.index]);
    });
    _load(_types.first);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load(String type) async {
    setState(() { _loading = true; _error = null; });
    try {
      _items[type] = await _repository.listByType(type);
    } catch (error) {
      _error = _message(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      return 'API indisponible. Vérifiez la connexion.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  Future<void> _edit([SiteContent? existing]) async {
    final type = _types[_tabs.index];
    final titleController = TextEditingController(text: existing?.title ?? '');
    final keyController = TextEditingController(text: existing?.key ?? '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    final orderController = TextEditingController(text: '${existing?.order ?? (_items[type]?.length ?? 0)}');
    String? imageUrl = existing?.imageUrl;
    String? publicId = existing?.publicId;
    bool visible = existing?.visible ?? true;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.anthraciteClair,
          title: Text(existing == null ? 'Ajouter du contenu' : 'Modifier le contenu'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: titleController, onChanged: (_) => setDialogState(() {}), decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: keyController, decoration: const InputDecoration(labelText: 'Clé interne (optionnel)')),
              TextField(controller: descriptionController, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: orderController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Ordre')),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Visible sur le site'), value: visible, activeColor: AppTheme.or, onChanged: (value) => setDialogState(() => visible = value)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: saving ? null : () async {
                  final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
                  if (file == null) return;
                  setDialogState(() => saving = true);
                  try {
                    final signed = await ApiService().client.post('/api/medias/signature', data: {'type': 'SITE'});
                    final data = signed.data as Map<String, dynamic>;
                    final upload = await Dio().post(data['uploadUrl'] as String, data: FormData.fromMap({
                      'file': await MultipartFile.fromFile(file.path),
                      'api_key': data['apiKey'], 'timestamp': data['timestamp'],
                      'folder': data['folder'], 'allowed_formats': data['allowed_formats'], 'signature': data['signature'],
                    }));
                    final result = upload.data as Map<String, dynamic>;
                    imageUrl = result['secure_url'] as String?;
                    publicId = result['public_id'] as String?;
                    if (context.mounted) {
                      setDialogState(() => saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image téléversée.')));
                    }
                  } catch (error) {
                    if (context.mounted) {
                      setDialogState(() => saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(error))));
                    }
                  }
                },
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(saving ? 'Téléversement...' : 'Ajouter une photo'),
              ),
              if (imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imageUrl!, height: 100, fit: BoxFit.cover)),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Annuler')),
            FilledButton(
              onPressed: saving || titleController.text.trim().isEmpty ? null : () async {
                setDialogState(() => saving = true);
                final content = SiteContent(id: existing?.id, type: type,
                  key: keyController.text.trim().isEmpty ? null : keyController.text.trim(),
                  title: titleController.text.trim(), description: descriptionController.text.trim(), imageUrl: imageUrl,
                  order: int.tryParse(orderController.text) ?? 0, visible: visible, publicId: publicId);
                try {
                  if (existing == null) { await _repository.create(content); } else { await _repository.update(content); }
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  await _load(type);
                } catch (error) {
                  if (dialogContext.mounted) {
                    setDialogState(() => saving = false);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(_message(error))));
                  }
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose(); keyController.dispose(); descriptionController.dispose(); orderController.dispose();
  }

  Future<void> _delete(SiteContent content) async {
    if (content.id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Supprimer ce contenu ?'), content: Text('« ${content.title} » sera retiré du site.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer'))],
    ));
    if (confirmed != true) return;
    try { await _repository.delete(content.id!); await _load(_types[_tabs.index]); }
    catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(error)))); }
  }

  @override
  Widget build(BuildContext context) {
    final type = _types[_tabs.index];
    final items = _items[type] ?? const <SiteContent>[];
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du site'), bottom: TabBar(controller: _tabs, isScrollable: true, indicatorColor: AppTheme.or, tabs: [for (final label in _labels) Tab(text: label)])),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: AppTheme.or, foregroundColor: AppTheme.anthracite, onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Ajouter')),
      body: RefreshIndicator(
        color: AppTheme.or, onRefresh: () => _load(type),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.or))
            : _error != null
                ? ListView(children: [const SizedBox(height: 140), Center(child: Text(_error!, textAlign: TextAlign.center)), Center(child: TextButton(onPressed: () => _load(type), child: const Text('Réessayer')))])
                : items.isEmpty
                    ? ListView(children: [const SizedBox(height: 150), Center(child: Text('Aucun contenu dans ${_labels[_tabs.index]}.'))])
                    : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 18, 16, 100), itemCount: items.length, itemBuilder: (context, index) => _card(items[index])),
      ),
    );
  }

  Widget _card(SiteContent content) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(12),
    leading: content.imageUrl == null ? const CircleAvatar(child: Icon(Icons.article_outlined)) : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(content.imageUrl!, width: 56, height: 56, fit: BoxFit.cover)),
    title: Text(content.title),
    subtitle: Text('${content.visible ? 'Visible' : 'Masqué'} · ordre ${content.order}\n${content.description ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis),
    isThreeLine: true,
    trailing: PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') _edit(content); if (value == 'delete') _delete(content); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Modifier')), PopupMenuItem(value: 'delete', child: Text('Supprimer'))]),
  ));
}
