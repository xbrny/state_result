import 'package:flutter/material.dart';

import 'expanded_single_child_scroll_view.dart';
import 'state_result.dart';
import 'state_result_builder.dart';

class PaginatedStateResultList<T> extends StatefulWidget {
  final _DataFetcher<T> dataFetcher;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ViewType viewType;
  final WidgetBuilder onIdle;
  final WidgetBuilder onEmpty;
  final WidgetBuilder onLoading;
  final ValueChangedWidgetBuilder<String> onFailure;
  final String emptyMessage;

  const PaginatedStateResultList({
    Key key,
    @required this.dataFetcher,
    this.itemBuilder,
    this.viewType = ViewType.list,
    this.onEmpty,
    this.onIdle,
    this.onLoading,
    this.onFailure,
    this.emptyMessage = 'No item',
  }) : super(key: key);

  @override
  _PaginatedStateResultListState<T> createState() =>
      _PaginatedStateResultListState<T>();
}

class _PaginatedStateResultListState<T>
    extends State<PaginatedStateResultList<T>> {
  final _scrollController = ScrollController();
  StateResult<List<T>> _itemsResult = StateResult.loading();
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreListener);
    _getList(refresh: true, showLoading: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreListener() {
    bool isExtentAfterZero = _scrollController.position.extentAfter == 0;
    if (_itemsResult.isSuccess &&
        isExtentAfterZero &&
        _hasMore &&
        !_isLoadingMore) {
      _getList();
    }
  }

  Future<void> _getList({
    bool refresh = false,
    bool showLoading = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
    } else if (_isLoadingMore) {
      return;
    }

    if (showLoading) setState(() => StateResult.loading());

    try {
      _isLoadingMore = true;
      final newItems =
          await widget.dataFetcher?.call(_currentPage++) ?? PaginatedData();
      final allItems = <T>[
        if (!refresh) ...(_itemsResult.data ?? []),
        ...(newItems.data ?? []),
      ];
      _isLoadingMore = false;
      _itemsResult = StateResult<List<T>>.success(allItems);
      _hasMore = newItems.hasNext ?? false;
    } catch (e) {
      _itemsResult = StateResult.failure(e);
    } finally {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _getList(refresh: true),
      child: StateResultBuilder<List<T>>(
        result: _itemsResult,
        onIdle: widget.onIdle,
        onFailure: widget.onFailure,
        onLoading: (context) => ExpandedSingleChildScrollView(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
        onSuccess: (context, list) {
          if ((list ?? []).isEmpty) {
            if (widget.onEmpty != null) {
              return widget.onEmpty(context);
            } else {
              return ExpandedSingleChildScrollView(
                alignment: Alignment.center,
                child: Text(widget.emptyMessage, textAlign: TextAlign.center),
              );
            }
          }
          return widget.viewType == ViewType.list
              ? _listBuilder(context, list)
              : _gridBuilder(context, list);
        },
      ),
    );
  }

  Widget _listBuilder(context, list) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      children: [
        ...list.map((item) {
          return widget.itemBuilder?.call(context, item) ?? SizedBox.shrink();
        }).toList(),
        if (_itemsResult.isSuccess && _hasMore)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _gridBuilder(context, list) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView(
            physics: NeverScrollableScrollPhysics(),
            addAutomaticKeepAlives: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            shrinkWrap: true,
            children: [
              ...list.map((item) {
                return widget.itemBuilder?.call(context, item) ??
                    SizedBox.shrink();
              }).toList(),
            ],
          ),
          if (_itemsResult.isSuccess && _hasMore)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class PaginatedData<T> {
  final bool hasNext;
  final List<T> data;

  PaginatedData({
    this.hasNext = false,
    this.data = const [],
  });

  PaginatedData copyWith({
    bool hasNext,
    List<T> data,
  }) {
    return PaginatedData(
      hasNext: hasNext ?? this.hasNext,
      data: data ?? this.data,
    );
  }
}

typedef _DataFetcher<T> = Future<PaginatedData<T>> Function(int page);

enum ViewType { list, grid }
