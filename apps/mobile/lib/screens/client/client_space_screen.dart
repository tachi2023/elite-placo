import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/brand_logo.dart';

/// Client-facing mobile space. It consumes the public follow-up endpoint and
/// deliberately never renders internal financial fields.
class ClientSpaceScreen extends StatefulWidget {
  const ClientSpaceScreen({super.key});

  @override
  State<ClientSpaceScreen> createState() => _ClientSpaceScreenState();
}

class _ClientSpaceScreenState extends State<ClientSpaceScreen> {
  final _codeController = TextEditingController();
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = false;
  int _tab = 0;
  int _note = 5;
  bool _avisLoading = false;
  String? _avisMessage;
  final _avisController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _avisController.dispose();
    super.dispose();
  }

  Future<void> _openFollowUp() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(
          () => _error = 'Saisissez le code remis par Élite Placo & Déco.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ApiService().client.get('/api/suivi/$code');
      final payload = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() => _data = payload);
    } on DioException catch (error) {
      if (!mounted) return;
      final payload = error.response?.data;
      final message = payload is Map ? payload['message']?.toString() : null;
      setState(
          () => _error = message ?? 'Code invalide ou serveur indisponible.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Impossible de charger le suivi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _data == null
            ? null
            : IconButton(
                tooltip: 'Changer de code',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() {
                  _data = null;
                  _tab = 0;
                }),
              ),
        title: const BrandLogo(centered: true, titleSize: 15),
      ),
      body: AppBackground(
        safeArea: false,
        child: _data == null ? _buildAccess() : _buildDashboard(),
      ),
      bottomNavigationBar: _data == null
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (value) => setState(() => _tab = value),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'Accueil'),
                NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: 'Projet'),
                NavigationDestination(
                    icon: Icon(Icons.photo_library_outlined),
                    selectedIcon: Icon(Icons.photo_library),
                    label: 'Photos'),
                NavigationDestination(
                    icon: Icon(Icons.notifications_none),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Alertes'),
                NavigationDestination(
                    icon: Icon(Icons.star_border_rounded),
                    selectedIcon: Icon(Icons.star_rounded),
                    label: 'Avis'),
              ],
            ),
    );
  }

  Widget _buildAccess() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: AppCard(
            accent: AppTheme.or,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.verified_user_outlined,
                    color: AppTheme.or, size: 48),
                const SizedBox(height: 18),
                Text('Votre projet, en toute clarté',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 10),
                const Text(
                    'Entrez le code unique transmis par notre équipe pour consulter l’avancement de votre chantier.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.grisClair, height: 1.5)),
                const SizedBox(height: 24),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  onSubmitted: (_) => _openFollowUp(),
                  decoration: const InputDecoration(
                      labelText: 'Code d’accès chantier',
                      hintText: 'Ex. DEMO-CLIENT',
                      prefixIcon: Icon(Icons.key_outlined)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.erreur)),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _loading ? null : _openFollowUp,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                      _loading ? 'Réveil du serveur...' : 'Ouvrir mon suivi'),
                ),
                const SizedBox(height: 14),
                const Text(
                    'Les données financières internes restent réservées à l’équipe Élite Placo & Déco.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.grisFonce, height: 1.4)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    switch (_tab) {
      case 1:
        return _buildProject();
      case 2:
        return _buildPhotos();
      case 3:
        return _buildAlerts();
      case 4:
        return _buildReview();
      default:
        return _buildHome();
    }
  }

  Widget _page(Widget child) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ResponsiveContent(child: child),
      );

  Widget _buildHome() {
    final name = (_data?['nomClient'] ?? 'Client').toString();
    final city = (_data?['ville'] ?? 'Cameroun').toString();
    final status = (_data?['statut'] ?? 'EN_COURS').toString();
    final progress = ((_data?['avancementPourcent'] as num?)?.toDouble() ?? 0)
        .clamp(0.0, 100.0)
        .toDouble();
    final steps = (_data?['etapes'] as List?)?.cast<Map>() ?? const <Map>[];
    final photos = (_data?['photos'] as List?)?.cast<Map>() ?? const <Map>[];
    final documents =
        (_data?['documents'] as List?)?.cast<Map>() ?? const <Map>[];
    final completedSteps =
        steps.where((step) => step['statut']?.toString() == 'TERMINEE').length;
    final heroPhoto = photos.isNotEmpty ? photos.first : null;
    return _page(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('ESPACE CLIENT',
          style: TextStyle(
              color: AppTheme.or,
              fontSize: 10,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Bonjour, ${name.split(' ').first}.',
          style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 6),
      Text('$city · ${_statusLabel(status)}',
          style: const TextStyle(color: AppTheme.grisFonce)),
      const SizedBox(height: 22),
      AppCard(
        padding: EdgeInsets.zero,
        accent: AppTheme.or,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 188,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (heroPhoto?['url'] != null)
                  Image.network(
                    heroPhoto!['url'].toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _projectHeroFallback(city),
                  )
                else
                  _projectHeroFallback(city),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xE6000000)],
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VOTRE CHANTIER',
                          style: TextStyle(
                              color: AppTheme.or,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text(city,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700)),
                      Text(_statusLabel(status),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      ResponsiveGrid(
        minTileWidth: 130,
        children: [
          _metricCard(
              Icons.percent_rounded, 'Avancement', '${progress.round()}%'),
          _metricCard(Icons.checklist_rounded, 'Étapes',
              '$completedSteps/${steps.length}'),
          _metricCard(
              Icons.photo_library_outlined, 'Photos', '${photos.length}'),
          _metricCard(
              Icons.description_outlined, 'Documents', '${documents.length}'),
        ],
      ),
      const SizedBox(height: 14),
      AppCard(
        accent: AppTheme.or,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const AppSectionTitle(
              title: 'Avancement du chantier',
              subtitle: 'Votre équipe met à jour ce dossier sur le terrain.'),
          const SizedBox(height: 20),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${progress.round()}%',
                style: const TextStyle(
                    color: AppTheme.or,
                    fontSize: 42,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(_statusLabel(status),
                style: const TextStyle(color: AppTheme.grisClair)),
          ]),
          const SizedBox(height: 12),
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: AppTheme.or)),
        ]),
      ),
      const SizedBox(height: 14),
      ResponsiveGrid(children: [
        _quickCard(Icons.photo_library_outlined, 'Photos',
            'Voir les dernières images', 2),
        _quickCard(
            Icons.timeline_rounded, 'Étapes', 'Consulter le parcours', 1),
        _quickCard(Icons.folder_open_outlined, 'Documents',
            'Ouvrir les éléments partagés', 3),
        _quickCard(Icons.star_border_rounded, 'Votre avis',
            'Partager votre expérience', 4),
      ]),
    ]));
  }

  Widget _projectHeroFallback(String city) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.or.withValues(alpha: .55),
              AppTheme.anthracite,
              const Color(0xFF080808),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
                right: -36,
                top: -54,
                child: Icon(Icons.architecture_rounded,
                    size: 210, color: Colors.white.withValues(alpha: .07))),
            Positioned(
                left: 18,
                top: 18,
                child: Text(city.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: .22),
                        letterSpacing: 4,
                        fontSize: 11))),
          ],
        ),
      );

  Widget _metricCard(IconData icon, String label, String value) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.or, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.grisFonce)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildProject() {
    final steps = (_data?['etapes'] as List?)?.cast<Map>() ?? const <Map>[];
    return _page(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppSectionTitle(
          title: 'Le parcours du projet',
          subtitle: 'Les étapes publiées par votre équipe chantier.'),
      const SizedBox(height: 18),
      AppCard(
          child: steps.isEmpty
              ? const Text('Les étapes seront publiées prochainement.',
                  style: TextStyle(color: AppTheme.grisFonce))
              : Column(children: [
                  for (var i = 0; i < steps.length; i++)
                    _step(steps[i], i == steps.length - 1)
                ])),
    ]));
  }

  Widget _step(Map step, bool last) {
    final state = step['statut']?.toString() ?? 'A_FAIRE';
    final done = state == 'TERMINEE';
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppTheme.succes : AppTheme.or, size: 22),
        if (!last) Container(width: 1, height: 42, color: Colors.white12),
      ]),
      const SizedBox(width: 14),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step['libelle']?.toString() ?? 'Étape',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        done
                            ? 'Terminée'
                            : state == 'EN_COURS'
                                ? 'En cours'
                                : 'À venir',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.grisFonce))
                  ]))),
    ]);
  }

  Widget _buildPhotos() {
    final photos = (_data?['photos'] as List?)?.cast<Map>() ?? const <Map>[];
    return _page(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppSectionTitle(
          title: 'Journal visuel',
          subtitle: 'Les photos publiées par Élite Placo & Déco.'),
      const SizedBox(height: 18),
      if (photos.isEmpty)
        const AppCard(
            child: Text('Aucune photo publiée pour le moment.',
                style: TextStyle(color: AppTheme.grisFonce)))
      else
        ResponsiveGrid(
            minTileWidth: 150,
            children: [for (final photo in photos) _photoCard(photo)]),
    ]));
  }

  Widget _photoCard(Map photo) => AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (photo['url'] != null)
              Image.network(photo['url'].toString(),
                  height: 145,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                      height: 145,
                      child: Icon(Icons.broken_image_outlined,
                          color: AppTheme.grisFonce))),
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(photo['libelle']?.toString() ?? 'Photo du chantier',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)))
          ])));

  Widget _buildAlerts() {
    final documents =
        (_data?['documents'] as List?)?.cast<Map>() ?? const <Map>[];
    return _page(
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppSectionTitle(
          title: 'Documents & alertes',
          subtitle: 'Les éléments partagés avec vous.'),
      const SizedBox(height: 18),
      AppCard(
          child: documents.isEmpty
              ? const Text('Aucun document disponible pour le moment.',
                  style: TextStyle(color: AppTheme.grisFonce))
              : Column(children: [
                  for (final document in documents)
                    ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.description_outlined,
                            color: AppTheme.or),
                        title: Text(document['libelle']?.toString() ??
                            'Document du chantier'),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () =>
                            _ouvrirDocument(document['url']?.toString()))
                ])),
    ]));
  }

  Widget _buildReview() {
    return _page(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionTitle(
          title: 'Votre expérience',
          subtitle: 'Votre avis aide notre équipe à améliorer chaque chantier.',
          icon: Icons.star_rounded,
        ),
        const SizedBox(height: 18),
        AppCard(
          accent: AppTheme.or,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Évaluez votre expérience',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Votre commentaire sera soumis à validation avant publication sur le site.',
                style: TextStyle(color: AppTheme.grisFonce, height: 1.45),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var value = 1; value <= 5; value++)
                    IconButton(
                      tooltip: '$value étoile${value > 1 ? 's' : ''}',
                      onPressed: _avisLoading
                          ? null
                          : () => setState(() => _note = value),
                      icon: Icon(
                        value <= _note
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 34,
                        color:
                            value <= _note ? AppTheme.or : AppTheme.grisFonce,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _avisController,
                maxLines: 5,
                maxLength: 1200,
                enabled: !_avisLoading,
                decoration: const InputDecoration(
                  labelText: 'Votre commentaire',
                  hintText: 'Dites-nous ce que vous avez pensé du chantier.',
                ),
              ),
              if (_avisMessage != null) ...[
                const SizedBox(height: 10),
                Text(_avisMessage!,
                    style: const TextStyle(color: AppTheme.grisClair)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _avisLoading ? null : _envoyerAvis,
                  icon: _avisLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send_rounded),
                  label: Text(_avisLoading ? 'Envoi...' : 'Envoyer mon avis'),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Future<void> _envoyerAvis() async {
    final commentaire = _avisController.text.trim();
    if (commentaire.isEmpty) {
      setState(
          () => _avisMessage = 'Écrivez un commentaire avant de l’envoyer.');
      return;
    }
    setState(() {
      _avisLoading = true;
      _avisMessage = null;
    });
    try {
      await ApiService().client.post('/api/avis', data: {
        'codePublic': _codeController.text.trim().toUpperCase(),
        'nomClient': (_data?['nomClient'] ?? 'Client').toString(),
        'note': _note,
        'commentaire': commentaire,
      });
      if (!mounted) return;
      _avisController.clear();
      setState(() =>
          _avisMessage = 'Merci. Votre avis sera publié après validation.');
    } on DioException catch (error) {
      if (!mounted) return;
      final payload = error.response?.data;
      final message = payload is Map ? payload['message']?.toString() : null;
      setState(() => _avisMessage =
          message ?? 'Impossible d’envoyer votre avis pour le moment.');
    } catch (_) {
      if (mounted) {
        setState(() =>
            _avisMessage = 'Impossible d’envoyer votre avis pour le moment.');
      }
    } finally {
      if (mounted) setState(() => _avisLoading = false);
    }
  }

  Widget _quickCard(IconData icon, String title, String subtitle, int tab) =>
      AppCard(
          onTap: () => setState(() => _tab = tab),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppTheme.or),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.grisFonce))
          ]));

  Future<void> _ouvrirDocument(String? rawUrl) async {
    final url = rawUrl == null ? null : Uri.tryParse(rawUrl);
    if (url == null ||
        !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Ce document ne peut pas être ouvert pour le moment.')),
      );
    }
  }

  String _statusLabel(String value) =>
      const {
        'A_VENIR': 'À venir',
        'EN_COURS': 'En cours',
        'EN_PAUSE': 'En pause',
        'TERMINE': 'Terminé',
        'ARCHIVE': 'Archivé'
      }[value] ??
      value;
}
