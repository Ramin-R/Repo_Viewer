import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase _sembastDatabase;
  final _store = StoreRef<int, String>('searchHistory');

  SearchHistoryRepository(this._sembastDatabase);

  static const historyLength = 10;

  Stream<List<String>> watchSearchTerms({String? filter}) {
    return _store
        .query(
          finder: filter != null && filter.isNotEmpty
              ? Finder(
                  filter: Filter.custom((record) => (record.value as String).contains(filter)),
                )
              : null,
        )
        .onSnapshots(_sembastDatabase.instance)
        .map(
          (records) => records.map((e) => e.value).toList(),
        );
  }

  Future<void> _addSearchTerm(String term, DatabaseClient dbClient) async {
    final existingKey = await _store.findKey(
      dbClient,
      finder: Finder(
        filter: Filter.custom((record) => record.value == term),
      ),
    );

    if (existingKey != null) {
      putSearchTermFirst(term);
      return;
    }

    await _store.add(dbClient, term);

    final count = await _store.count(_sembastDatabase.instance);
    if (count > historyLength) {
      _store.delete(
        dbClient,
        finder: Finder(limit: count - historyLength),
      );
    }
  }

  Future<void> _deleteSearchTerm(String term, DatabaseClient dbClient) async {
    await _store.delete(
      dbClient,
      finder: Finder(
        filter: Filter.custom((record) => record.value == term),
      ),
    );
  }

  Future<void> addSearchTerm(String term) => _addSearchTerm(term, _sembastDatabase.instance);

  Future<void> deleteSearchTerm(String term) => _deleteSearchTerm(term, _sembastDatabase.instance);

  Future<void> putSearchTermFirst(String term) async {
    _sembastDatabase.instance.transaction((txn) async {
      await _deleteSearchTerm(term, txn);
      await _addSearchTerm(term, txn);
    });
  }
}
