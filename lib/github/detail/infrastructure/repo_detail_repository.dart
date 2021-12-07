import 'package:dartz/dartz.dart';
import 'package:repo_viewer/core/domain/fresh.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/detail/domain/github_repo_detail.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_local_service.dart';
import 'package:repo_viewer/github/detail/infrastructure/repo_detail_remote_service.dart';

class RepoDetailRepository {
  final RepoDetailRemoteService _remoteService;
  final RepoDetailLocalService _localService;

  RepoDetailRepository(this._remoteService, this._localService);
  Future<Either<GithubFailure, Fresh<GithubRepoDetail?>>> getRepoDetail(String fullRepoName) async {
    try {
      final htmlRemoteResponse = await _remoteService.getReadmeHtml(fullRepoName);

      return right(
        await htmlRemoteResponse.when(
          noConnection: () async =>
              Fresh.no(entity: (await _localService.getRepoDetail(fullRepoName))?.toDomain()),
          notModified: (_) async {
            final cached = await _localService.getRepoDetail(fullRepoName);
            final starred = await _remoteService.getStarredStatus(fullRepoName);

            if (starred == null) {
              return Fresh.yes(entity: cached?.toDomain());
            }

            return Fresh.yes(entity: cached?.copyWith(starred: starred).toDomain());
          },
          withNewData: (html, _) async {
            final starred = await _remoteService.getStarredStatus(fullRepoName);
            final dto = GithubRepoDetailDTO(
              fullName: fullRepoName,
              html: html,
              starred: starred ?? false,
            );

            _localService.upsertRepoDetail(dto);

            return Fresh.yes(entity: dto.toDomain());
          },
        ),
      );
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }

  /// Returns right(null) if there is no internet connection
  Future<Either<GithubFailure, Unit?>> switchStarredStatus(GithubRepoDetail repoDetail) async {
    try {
      final actionCompleted = await _remoteService.switchStarredStatus(
        repoDetail.fullName,
        isCurrentlyStarred: repoDetail.starred,
      );
      return right(actionCompleted);
    } on RestApiException catch (e) {
      return left(GithubFailure.api(e.errorCode));
    }
  }
}
