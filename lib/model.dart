
import 'package:both_loadmore_listview/repository.dart';
import 'package:flutter/cupertino.dart';

import 'main.dart';

class LoadMoreModel extends ChangeNotifier {

  var _repository = LoadMoreRepository();

  List<String> data = [];

  final int pagination = 20;
  int limit;
  int offset;
  final scrollController = ScrollController();
  bool loading = false;

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
    });
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

  Future<void> getData() async {
    try {
      final notify = await _repository.fetchData(limit: limit, offset: offset);
      data += notify;
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
