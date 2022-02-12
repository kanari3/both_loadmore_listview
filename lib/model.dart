import 'package:both_loadmore_listview/repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LoadMoreModel extends ChangeNotifier {

  double position = 0.0 ;
  double sensitivityFactor = 20.0 ;
  // 下方向にスクロールしているか
  bool positiveScroll = true;
  bool positionJumpLock = false;
  int logicalZeroPosition = 0;
  int globalZeroPosition = 0;

  var _repository = LoadMoreRepository();

  List<String> data = [];

  final int pagination = 20;
  int limit;
  int positiveOffset;
  int negativeOffset;
  bool loading = false;
  bool loadingReverse = false;

  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  LoadMoreModel() {
    refresh();
  }

  loadMore() async {
    if (loading) {
      return;
    }
    loading = true;
    notifyListeners();

    await getData();
    loading = false;
    notifyListeners();
  }

  loadMoreReverse() async {
    if (loading) {
      return;
    }
    loading = true;
    notifyListeners();

    await getDataReverse();
    loading = false;
    notifyListeners();
  }

  Future<List<String>> refresh() async {
    data.clear();
    positionJumpLock = false;
    limit = pagination;
    positiveOffset = 0;
    negativeOffset = 0;
    await getData();
    return data;
  }

  Future<void> getData() async {
    try {
      final fetch = await _repository.fetchData(limit: limit, offset: positiveOffset);
      data += fetch;
      limit += pagination;
      positiveOffset += pagination;

    } catch (err) {
      print(err.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> getDataReverse() async {
    try {
      final fetch = await _repository.fetchDataReverse(limit: limit, offset: negativeOffset);

      logicalZeroPosition = fetch.length;
      globalZeroPosition += fetch.length;

      data = fetch + data;
      limit += pagination;
      negativeOffset += pagination;
    } catch (err) {
      print(err.toString());
    } finally {
      notifyListeners();
    }
  }

}
