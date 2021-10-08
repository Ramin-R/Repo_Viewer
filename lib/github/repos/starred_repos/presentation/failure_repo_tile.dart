import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/provider.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';

class FailureRepoTile extends StatelessWidget {
  final GithubFailure failure;
  const FailureRepoTile({
    Key? key,
    required this.failure,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTileTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        tileColor: Theme.of(context).errorColor,
        textColor: Theme.of(context).colorScheme.onError,
        iconColor: Theme.of(context).colorScheme.onError,
        child: ListTile(
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.warning,
            ),
          ),
          title: const Text('An error occured, please retry'),
          subtitle: Text(failure.map(api: (_) => 'API returned ${_.errorCode}')),
          trailing: IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: () {
              context.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
            },
          ),
        ),
      ),
    );
  }
}
