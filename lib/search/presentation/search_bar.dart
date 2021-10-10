import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends StatefulWidget {
  final String title;
  final String hint;
  final Widget body;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;
  const SearchBar({
    Key? key,
    required this.title,
    required this.hint,
    required this.body,
    required this.onShouldNavigateToResultPage,
    required this.onSignOutButtonPressed,
  }) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late FloatingSearchBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloatingSearchBarController();
    Future.microtask(() => context.read(searchHistoryNotifierProvider.notifier).watchSearchTerms());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void pushPageAndPutFirstInHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(searchTerm);
      context.read(searchHistoryNotifierProvider.notifier).putSearchTermFirst(searchTerm);
      _controller.close();
    }

    void pushPageAndAddToHistory(String searchTerm) {
      widget.onShouldNavigateToResultPage(searchTerm);
      context.read(searchHistoryNotifierProvider.notifier).addSearchTerm(searchTerm);
      _controller.close();
    }

    return FloatingSearchBar(
      controller: _controller,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to search 👆',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      hint: widget.hint,
      body: FloatingSearchBarScrollNotifier(child: widget.body),
      onQueryChanged: (query) =>
          context.read(searchHistoryNotifierProvider.notifier).watchSearchTerms(filter: query),
      onSubmitted: (query) => pushPageAndAddToHistory(query),
      actions: [
        FloatingSearchBarAction.icon(
          icon: const Icon(MdiIcons.logoutVariant),
          onTap: widget.onSignOutButtonPressed,
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, animation) {
        return Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          elevation: 4,
          child: Consumer(
            builder: (context, ref, child) {
              final searchHistoryState = ref.watch(searchHistoryNotifierProvider);
              return searchHistoryState.map(
                data: (history) {
                  if (_controller.query.isEmpty && history.value.isEmpty) {
                    return Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        'Start searching',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (history.value.isEmpty) {
                    return ListTile(
                      leading: const Icon(MdiIcons.magnify),
                      title: Text(
                        _controller.query,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => pushPageAndAddToHistory(_controller.query),
                    );
                  }
                  return Column(
                    children: history.value
                        .map(
                          (term) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(
                              term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: CircularButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                context
                                    .read(searchHistoryNotifierProvider.notifier)
                                    .deleteSearchTerm(term);
                              },
                            ),
                            onTap: () => pushPageAndPutFirstInHistory(term),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: (_) => const ListTile(
                  title: LinearProgressIndicator(),
                ),
                error: (v) => Container(),
              );
            },
          ),
        );
      },
    );
  }
}
