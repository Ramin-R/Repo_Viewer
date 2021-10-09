import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/extensions.dart';
import 'package:repo_viewer/github/repos/searched_repos/infrastructure/searched_repos_remote_service.dart';

class SearchedReposRepository {
  final SearchedReposRemoteService _remoteService;

  SearchedReposRepository(this._remoteService);

  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> getStarredReposPage(
      String query, int page) async {
    try {
      final remoteResponse = await _remoteService.getSearchedReposPage(query, page);

      return right(
        await remoteResponse.maybeWhen(
          withNewData: (data, maxPage) => Fresh.yes(
            entity: data.toDomain(),
            isNextPageAvailable: page < maxPage,
          ),
          orElse: () => Fresh.no(entity: []),
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
