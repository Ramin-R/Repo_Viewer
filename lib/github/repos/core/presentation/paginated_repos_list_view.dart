import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/repos/core/application/paginated_repos_notifier.dart';
import 'package:repo_viewer/github/repos/core/presentation/failure_repo_tile.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile.dart';

import 'loading_repo_tile.dart';

class PaginatedReposListView extends StatefulWidget {
  final AutoDisposeStateNotifierProvider<PaginatedReposNotifier, PaginatedReposState>
      reposNotifierProvider;
  final void Function(BuildContext context) getNextPage;
  final String noResultsMessage;

  const PaginatedReposListView({
    Key? key,
    required this.reposNotifierProvider,
    required this.getNextPage,
    required this.noResultsMessage,
  }) : super(key: key);

  @override
  State<PaginatedReposListView> createState() => _PaginatedReposListViewState();
}

class _PaginatedReposListViewState extends State<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(widget.reposNotifierProvider);
        return ProviderListener<PaginatedReposState>(
          provider: widget.reposNotifierProvider,
          onChange: (context, state) {
            state.map(
              initial: (_) => canLoadNextPage = false,
              loadInProgress: (_) => canLoadNextPage = false,
              loadSuccess: (_) {
                if (!_.repos.isFresh && !hasAlreadyShownNoConnectionToast) {
                  hasAlreadyShownNoConnectionToast = true;
                  showNoConnectionToast(
                    context,
                    "You're not online, some information may be outdated.",
                  );
                }
                canLoadNextPage = _.isNextPageAvailable;
              },
              loadFailure: (_) => canLoadNextPage = false,
            );
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // metrics.pixels:
              final metrics = notification.metrics;
              final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
              if (canLoadNextPage && metrics.pixels >= limit) {
                canLoadNextPage = false;
                widget.getNextPage(context);
              }
              return false;
            },
            child: state.maybeWhen(
              loadSuccess: (repos, _) => repos.entity.isEmpty,
              orElse: () => false,
            )
                ? NoResultsDisplay(
                    message: widget.noResultsMessage,
                  )
                : _PaginatedListView(state: state),
          ),
        );
      },
    );
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({Key? key, required this.state}) : super(key: key);

  final PaginatedReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: FloatingSearchBar.of(context)?.widget.height ?? 0),
      itemCount: state.map(
        initial: (s) => 0,
        loadInProgress: (s) => s.repos.entity.length + s.itemsPerPage,
        loadSuccess: (s) => s.repos.entity.length,
        loadFailure: (s) => s.repos.entity.length + 1,
      ),
      itemBuilder: (context, index) {
        return state.map(
          initial: (s) => Container(),
          loadInProgress: (s) {
            if (index < s.repos.entity.length) {
              return RepoTile(repo: s.repos.entity[index]);
            }

            return const LoadingRepoTile();
          },
          loadSuccess: (s) => RepoTile(repo: s.repos.entity[index]),
          loadFailure: (s) {
            if (index < s.repos.entity.length) {
              return RepoTile(repo: s.repos.entity[index]);
            }

            return FailureRepoTile(failure: s.failure);
          },
        );
      },
    );
  }
}
