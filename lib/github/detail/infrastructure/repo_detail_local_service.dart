import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers_cache.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class RepoDetailLocalService {
  static const cacheSize = 50;
  final SembastDatabase _sembastDatabase;
  final GithubHeadersCache _headersCache;
  final _store = stringMapStoreFactory.store('repoDetail');

  RepoDetailLocalService(this._sembastDatabase, this._headersCache);

  Future<void> upsertRepoDetail(GithubRepoDetailDTO dto) async {
    await _store.record(dto.fullName).put(_sembastDatabase.instance, dto.toSembast());

    final keys = await _store.findKeys(
      _sembastDatabase.instance,
      finder: Finder(
        sortOrders: [SortOrder('lastUsed', false)],
      ),
    );

    if (keys.length > cacheSize) {
      final keysToRemove = keys.sublist(cacheSize, keys.length);
      for (final key in keysToRemove) {
        await _store.record(key).delete(_sembastDatabase.instance);
        await _headersCache.deleteHeaders(Uri.https('api.github.com', '/repos/$key/readme'));
      }
    }
  }

  Future<GithubRepoDetailDTO?> getRepoDetail(String fullRepoName) async {
    final json = await _store.record(fullRepoName).get(_sembastDatabase.instance);

    if (json == null) {
      return null;
    }

    await _store
        .record(fullRepoName)
        .update(_sembastDatabase.instance, {'lastUsed': Timestamp.now()});

    return GithubRepoDetailDTO.fromJson(json);
  }
}
