import 'package:both_loadmore_listview/repository.dart';
import 'package:flutter/cupertino.dart';

class LoadMoreModel extends ChangeNotifier {

  var _repository = LoadMoreRepository();

  List<String> data = [];

  final int pagination = 20;
  int limit;
  int offset;
  final scrollController = ScrollController();
  bool loading = false;
  bool loadingReverse = false;

  LoadMoreModel() {
    setListener();
    refresh();
  }

  setListener() {
    scrollController.addListener(() {
      final max = scrollController.position.maxScrollExtent;
      final min = scrollController.position.minScrollExtent;
      final offset = scrollController.offset;

      if (max == offset) {
        loadMore();
      }

      if (min == offset) {
        loadMoreReverse();
      }

    });
  }

  loadMoreReverse() async {
    if (!loading) {
      loading = true;
      notifyListeners();

      await getDataReverse();
      loading = false;
      notifyListeners();
    }
  }

  loadMore() async {
    if (!loading) {
      loading = true;
      notifyListeners();

      await getData();
      loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> refresh() async {
    data.clear();
    limit = pagination;
    offset = 0;
    await getData();
    return data;
  }

  Future<void> getDataReverse() async {
    try {
      final fetch = await _repository.fetchDataReverse(limit: limit, offset: offset);
      data = fetch + data;
      limit += pagination;
      offset += pagination;
    } catch (err) {
    } finally {
      notifyListeners();
    }
  }

  Future<void> getData() async {
    try {
      final fetch = await _repository.fetchData(limit: limit, offset: offset);
      data += fetch;
      limit += pagination;
      offset += pagination;
    } catch (err) {
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
