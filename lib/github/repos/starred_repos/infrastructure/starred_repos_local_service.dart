import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/core/infrastructure/pagination_config.dart';
import 'package:sembast/sembast.dart';

class StarredReposLocalService {
  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');
  static const _numInPage = PaginationConfig.itemsPerPage;

  StarredReposLocalService(this._sembastDatabase);

  Future<void> upsertPage(List<GithubRepoDTO> dtos, int page) async {
    final sembastPage = page - 1;

    await _store
        .records(Iterable.generate(dtos.length, (i) => i + sembastPage * _numInPage))
        .put(_sembastDatabase.instance, dtos.map((e) => e.toJson()).toList());
  }

  Future<List<GithubRepoDTO>> getPage(int page) async {
    final sembastPage = page - 1;

    final records = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(
        offset: sembastPage * _numInPage,
        limit: _numInPage,
      ),
    );

    return records.map((e) => GithubRepoDTO.fromJson(e.value)).toList();
  }

  Future<int> getLocalPageCount() async {
    final count = await _store.count(_sembastDatabase.instance);
    return (count / _numInPage).ceil();
  }
}
