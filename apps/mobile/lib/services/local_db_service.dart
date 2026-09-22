import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'dart:convert';

/// Service gérant la base SQLite locale chiffrée (Offline-First, Phase 3).
/// Utilise sqflite_sqlcipher pour chiffrer la base de données avec une clé
/// stockée de manière sécurisée (Keystore/Keychain via flutter_secure_storage).
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  static Database? _database;
  final _secureStorage = const FlutterSecureStorage();
  static const String _dbKeyName = 'db_encryption_key';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Récupère ou génère une clé de chiffrement sécurisée.
  Future<String> _getOrGenerateEncryptionKey() async {
    String? key = await _secureStorage.read(key: _dbKeyName);
    if (key == null) {
      // Génère une clé aléatoire forte
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      key = base64UrlEncode(values);
      await _secureStorage.write(key: _dbKeyName, value: key);
    }
    return key;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'elite_placo_secure.db');
    
    final password = await _getOrGenerateEncryptionKey();

    return await openDatabase(
      path,
      password: password,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table Chantiers locaux
    await db.execute('''
      CREATE TABLE chantier_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomClient TEXT NOT NULL,
        ville TEXT,
        typeTravaux TEXT,
        statut TEXT NOT NULL,
        montantDevis REAL NOT NULL,
        dateCreation TEXT NOT NULL,
        synchronise INTEGER NOT NULL DEFAULT 0,
        apiId INTEGER
      )
    ''');

    // Table Mouvements
    await db.execute('''
      CREATE TABLE mouvement_local (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        typeMouvement TEXT NOT NULL,
        date TEXT NOT NULL,
        montant REAL NOT NULL,
        chantierId INTEGER NOT NULL,
        nature TEXT,
        categorie TEXT,
        description TEXT,
        synchronise INTEGER NOT NULL DEFAULT 0,
        apiId INTEGER
      )
    ''');

    // Table File d'attente pour la synchronisation des actions (POST/PUT/DELETE)
    await db.execute('''
      CREATE TABLE file_attente_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entite TEXT NOT NULL,
        action TEXT NOT NULL, -- 'CREATION', 'MODIFICATION', 'SUPPRESSION'
        donneesJson TEXT NOT NULL,
        localId INTEGER,
        dateEnregistrement TEXT NOT NULL,
        operationId TEXT NOT NULL UNIQUE,
        tentatives INTEGER NOT NULL DEFAULT 0,
        derniereErreur TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_meta (
        cle TEXT PRIMARY KEY,
        valeur TEXT NOT NULL
      )
    ''');
    
    // Vous pourrez ajouter les tables pour ouvrier et fiche_metrage ici.
  }

  Future<void> _onUpgrade(Database db, int ancienneVersion, int nouvelleVersion) async {
    if (ancienneVersion < 2) {
      await db.execute("ALTER TABLE file_attente_sync ADD COLUMN operationId TEXT");
      await db.execute("ALTER TABLE file_attente_sync ADD COLUMN tentatives INTEGER NOT NULL DEFAULT 0");
      await db.execute("ALTER TABLE file_attente_sync ADD COLUMN derniereErreur TEXT");
      await db.execute("UPDATE file_attente_sync SET operationId = 'legacy-' || id WHERE operationId IS NULL");
      await db.execute('CREATE UNIQUE INDEX idx_file_attente_operation ON file_attente_sync(operationId)');
      await db.execute('CREATE TABLE sync_meta (cle TEXT PRIMARY KEY, valeur TEXT NOT NULL)');
    }
  }

  // --- Outils CRUD génériques pour le cache local ---

  Future<int> inserer(String table, Map<String, dynamic> donnees) async {
    final db = await database;
    return await db.insert(table, donnees, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> lister(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> mettreAJour(String table, Map<String, dynamic> donnees, int id) async {
    final db = await database;
    return await db.update(table, donnees, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> viderTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // --- Gestion de la file d'attente ---
  Future<void> ajouterAFileAttente(String entite, String action, Map<String, dynamic> donnees, int localId) async {
    final db = await database;
    final operationId = '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
    await db.insert('file_attente_sync', {
      'entite': entite,
      'action': action,
      'donneesJson': jsonEncode(donnees),
      'localId': localId,
      'dateEnregistrement': DateTime.now().toIso8601String(),
      'operationId': operationId,
      'tentatives': 0,
    });
  }

  Future<List<Map<String, dynamic>>> listerFileAttente({int limite = 25}) async {
    final db = await database;
    return await db.query('file_attente_sync', orderBy: 'id ASC', limit: limite);
  }

  Future<void> supprimerDeFileAttente(int id) async {
    final db = await database;
    await db.delete('file_attente_sync', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> marquerEchecFileAttente(int id, String message) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE file_attente_sync SET tentatives = tentatives + 1, derniereErreur = ? WHERE id = ?',
      [message, id],
    );
  }

  Future<String?> lireCurseurSynchronisation() async {
    final db = await database;
    final rows = await db.query('sync_meta', where: 'cle = ?', whereArgs: ['curseur']);
    return rows.isEmpty ? null : rows.first['valeur'] as String;
  }

  Future<void> enregistrerCurseurSynchronisation(String curseur) async {
    final db = await database;
    await db.insert(
      'sync_meta',
      {'cle': 'curseur', 'valeur': curseur},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
