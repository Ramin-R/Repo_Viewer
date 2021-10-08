import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/core/domain/github_repo.dart';
import 'package:repo_viewer/github/core/infrastructure/user_dto.dart';

part 'github_repo_dto.freezed.dart';
part 'github_repo_dto.g.dart';

@freezed
class GithubRepoDTO with _$GithubRepoDTO {
  const GithubRepoDTO._();
  const factory GithubRepoDTO({
    required UserDTO owner,
    required String name,
    @JsonKey(defaultValue: '') required String description,
    @JsonKey(name: 'stargazers_count') required int stargazersCount,
  }) = _GithubRepoDTO;

  factory GithubRepoDTO.fromJson(Map<String, dynamic> json) => _$GithubRepoDTOFromJson(json);

  factory GithubRepoDTO.fromDomain(GithubRepo g) {
    return GithubRepoDTO(
      owner: UserDTO.fromDomain(g.owner),
      name: g.name,
      description: g.description,
      stargazersCount: g.stargazersCount,
    );
  }

  GithubRepo toDomain() {
    return GithubRepo(
      name: name,
      description: description,
      owner: owner.toDomain(),
      stargazersCount: stargazersCount,
    );
  }
}
