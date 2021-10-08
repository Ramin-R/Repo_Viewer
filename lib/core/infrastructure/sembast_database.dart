import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast_io.dart';

class SembastDatabase {
  late Database _instance;
  Database get instance => _instance;

  bool _hasBeenInitialized = false;

  Future<void> init() async {
    if (_hasBeenInitialized) return;
    _hasBeenInitialized = true;

    final dbDirectory = await getApplicationDocumentsDirectory();
    await dbDirectory.create(recursive: true);
    final dbPath = p.join(dbDirectory.path, 'db.sembast');

    _instance = await databaseFactoryIo.openDatabase(dbPath);
  }
}
