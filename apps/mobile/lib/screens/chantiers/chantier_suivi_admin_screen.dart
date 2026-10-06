import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../repositories/chantier_admin_repository.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ChantierSuiviAdminScreen extends StatefulWidget {
  final int chantierId;
  const ChantierSuiviAdminScreen({super.key, required this.chantierId});

  @override
  State<ChantierSuiviAdminScreen> createState() => _ChantierSuiviAdminScreenState();
}

class _ChantierSuiviAdminScreenState extends State<ChantierSuiviAdminScreen>
    with SingleTickerProviderStateMixin {
  final _repository = ChantierAdminRepository();
  final _picker = ImagePicker();
  late final TabController _tabs;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _etapes = [];
  List<Map<String, dynamic>> _photos = [];
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (mounted) setState(() {});
    });
    _charger();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _charger() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _repository.etapes(widget.chantierId),
        _repository.photos(widget.chantierId),
        _repository.documents(widget.chantierId),
      ]);
      _etapes = results[0]; _photos = results[1]; _documents = results[2];
    } catch (error) {
      _error = error is DioException ? 'Impossible de charger le suivi du chantier.' : error.toString();
    } finally { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _ajouterEtape() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Nouvelle étape'),
      content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Libellé')),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim().isNotEmpty), child: const Text('Ajouter'))],
    ));
    if (ok != true) return;
    await _repository.ajouterEtape(widget.chantierId, controller.text.trim(), _etapes.length + 1);
    controller.dispose();
    await _charger();
  }

  Future<void> _changerStatut(Map<String, dynamic> etape, String statut) async {
    final copy = Map<String, dynamic>.from(etape)..['statut'] = statut;
    await _repository.modifierEtape(widget.chantierId, copy);
    await _charger();
  }

  Future<void> _ajouterMedia(String kind) async {
    final label = TextEditingController();
    String? filePath;
    String? fileName;
    bool uploading = false;
    final ok = await showDialog<bool>(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
      title: Text(kind == 'photos' ? 'Ajouter une photo' : 'Ajouter un document'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: label, decoration: const InputDecoration(labelText: 'Libellé')),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: uploading ? null : () async {
            final path = kind == 'photos'
                ? (await _picker.pickImage(source: ImageSource.gallery))?.path
                : (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']))?.files.single.path;
            if (path != null) setDialogState(() { filePath = path; fileName = path.split(RegExp(r'[/\\]')).last; });
          },
          icon: const Icon(Icons.attach_file),
          label: Text(fileName ?? (kind == 'photos' ? 'Choisir une photo' : 'Choisir un PDF')),
        ),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')), FilledButton(onPressed: filePath == null || uploading ? null : () => Navigator.pop(context, true), child: const Text('Téléverser'))],
      ),
    ));
    if (ok != true || filePath == null) { label.dispose(); return; }
    try {
      final type = kind == 'photos' ? 'PHOTO' : 'DOCUMENT';
      final signed = await ApiService().client.post('/api/medias/signature', data: {'chantierId': widget.chantierId, 'type': type});
      final data = signed.data as Map<String, dynamic>;
      final upload = await Dio().post(data['uploadUrl'] as String, data: FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath!),
        'api_key': data['apiKey'], 'timestamp': data['timestamp'], 'folder': data['folder'],
        'allowed_formats': data['allowed_formats'], 'signature': data['signature'],
      }));
      final result = upload.data as Map<String, dynamic>;
      await _repository.ajouterMedia(widget.chantierId, kind, url: result['secure_url'] as String, publicId: result['public_id'] as String?, libelle: label.text.trim());
      await _charger();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload impossible : $error')));
    } finally { label.dispose(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Suivi du chantier'), bottom: TabBar(controller: _tabs, tabs: const [Tab(text: 'Étapes'), Tab(text: 'Photos'), Tab(text: 'Documents')])),
    floatingActionButton: _loading ? null : FloatingActionButton.extended(
      backgroundColor: AppTheme.or, foregroundColor: AppTheme.anthracite,
      onPressed: () => _tabs.index == 0 ? _ajouterEtape() : _ajouterMedia(_tabs.index == 1 ? 'photos' : 'documents'),
      icon: const Icon(Icons.add), label: Text(_tabs.index == 0 ? 'Étape' : 'Fichier'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.or))
        : _error != null
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!), TextButton(onPressed: _charger, child: const Text('Réessayer'))]))
            : TabBarView(controller: _tabs, children: [_etapesView(), _mediaView(_photos, 'photos'), _mediaView(_documents, 'documents')]),
  );

  Widget _etapesView() => RefreshIndicator(color: AppTheme.or, onRefresh: _charger, child: ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 100), itemCount: _etapes.length,
    itemBuilder: (context, index) { final step = _etapes[index]; final status = step['statut']?.toString() ?? 'A_FAIRE';
      return Card(child: ListTile(leading: CircleAvatar(backgroundColor: _statusColor(status), child: Text('${index + 1}')), title: Text(step['libelle']?.toString() ?? ''), subtitle: Text(status.replaceAll('_', ' ')), trailing: PopupMenuButton<String>(onSelected: (value) => _changerStatut(step, value), itemBuilder: (_) => const [PopupMenuItem(value: 'A_FAIRE', child: Text('À faire')), PopupMenuItem(value: 'EN_COURS', child: Text('En cours')), PopupMenuItem(value: 'TERMINEE', child: Text('Terminée'))]))); },
  ));

  Widget _mediaView(List<Map<String, dynamic>> media, String kind) => RefreshIndicator(color: AppTheme.or, onRefresh: _charger, child: media.isEmpty
      ? ListView(children: [const SizedBox(height: 160), Center(child: Text('Aucun élément pour le moment.'))])
      : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 18, 16, 100), itemCount: media.length, itemBuilder: (context, index) { final item = media[index]; final id = (item['id'] as num).toInt(); final visible = item['visibleClient'] as bool? ?? true; return Card(child: ListTile(leading: kind == 'photos' && item['url'] != null ? Image.network(item['url'], width: 54, height: 54, fit: BoxFit.cover) : const Icon(Icons.description_outlined, color: AppTheme.or), title: Text(item['libelle']?.toString().isNotEmpty == true ? item['libelle'] : 'Sans titre'), subtitle: Text(visible ? 'Visible côté client' : 'Masqué côté client'), trailing: Switch(value: visible, activeColor: AppTheme.or, onChanged: (value) async { await _repository.modifierVisibilite(widget.chantierId, kind, id, value); await _charger(); }))); }),
    );

  Color _statusColor(String value) { if (value == 'TERMINEE') return AppTheme.succes; if (value == 'EN_COURS') return AppTheme.or; return AppTheme.grisFonce; }
}
