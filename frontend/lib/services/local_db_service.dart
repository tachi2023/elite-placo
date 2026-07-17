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
      version: 1,
      onCreate: _onCreate,
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
        dateEnregistrement TEXT NOT NULL
      )
    ''');
    
    // Vous pourrez ajouter les tables pour ouvrier et fiche_metrage ici.
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
    await db.insert('file_attente_sync', {
      'entite': entite,
      'action': action,
      'donneesJson': jsonEncode(donnees),
      'localId': localId,
      'dateEnregistrement': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> listerFileAttente() async {
    final db = await database;
    return await db.query('file_attente_sync', orderBy: 'id ASC');
  }

  Future<void> supprimerDeFileAttente(int id) async {
    final db = await database;
    await db.delete('file_attente_sync', where: 'id = ?', whereArgs: [id]);
  }
}
