import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.gr.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_list_view.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

class SearchedReposPage extends StatefulWidget {
  final String searchTerm;
  const SearchedReposPage({Key? key, required this.searchTerm}) : super(key: key);

  @override
  State<SearchedReposPage> createState() => _SearchedReposPageState();
}

class _SearchedReposPageState extends State<SearchedReposPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () {
        context
            .read(searchedReposNotifierProvider.notifier)
            .getFirstSearchedReposPage(widget.searchTerm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        title: widget.searchTerm,
        hint: 'Search all repositories',
        onShouldNavigateToResultPage: (term) => AutoRouter.of(context).pushAndPopUntil(
          SearchedReposRoute(searchTerm: term),
          predicate: (route) => route.settings.name == StarredReposRoute.name,
        ),
        onSignOutButtonPressed: () => context.read(authNotifierProvider.notifier).signOut(),
        body: PaginatedReposListView(
          reposNotifierProvider: searchedReposNotifierProvider,
          getNextPage: (context) => context
              .read(searchedReposNotifierProvider.notifier)
              .getNextSearchedReposPage(widget.searchTerm),
          noResultsMessage: "This is all we could find for your search term.",
        ),
      ),
    );
  }
}
