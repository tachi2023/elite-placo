/// Web facade for the native encrypted SQLite service.
///
/// The browser uses the PWA cache for read-only offline data. Native builds
/// use the encrypted SQLite implementation instead.
class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Future<dynamic> get database async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<int> inserer(String table, Map<String, dynamic> donnees) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<List<Map<String, dynamic>>> lister(String table) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<int> mettreAJour(
          String table, Map<String, dynamic> donnees, int id) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<void> viderTable(String table) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<void> ajouterAFileAttente(String entite, String action,
          Map<String, dynamic> donnees, int localId) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<List<Map<String, dynamic>>> listerFileAttente(
          {int limite = 25}) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<void> supprimerDeFileAttente(int id) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<void> marquerEchecFileAttente(int id, String message) async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<String?> lireCurseurSynchronisation() async =>
      throw UnsupportedError('SQLite is not used by the web build.');

  Future<void> enregistrerCurseurSynchronisation(String curseur) async =>
      throw UnsupportedError('SQLite is not used by the web build.');
}
