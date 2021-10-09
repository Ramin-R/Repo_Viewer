import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/github/core/shared/providers.dart';
import 'package:repo_viewer/github/repos/core/presentation/paginated_repos_list_view.dart';

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
            .getNextSearchedReposPage(widget.searchTerm);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchTerm),
        actions: [
          IconButton(
            onPressed: () => context.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(MdiIcons.logoutVariant),
          ),
        ],
      ),
      body: PaginatedReposListView(
        reposNotifierProvider: searchedReposNotifierProvider,
        getNextPage: (context) => context
            .read(searchedReposNotifierProvider.notifier)
            .getNextSearchedReposPage(widget.searchTerm),
        noResultsMessage: "This is all we could find for your search term.",
      ),
    );
  }
}