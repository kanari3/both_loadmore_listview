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

  var _repository = LoadMoreRepository();

  List<String> data = [];

  final int pagination = 20;
  int limit;
  int offset;
  bool loading = false;
  bool loadingReverse = false;

  final itemScrollController = ItemScrollController();
  final itemPositionsListener = ItemPositionsListener.create();

  LoadMoreModel() {
    refresh();
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

  loadMoreReverse() async {
    if (!loading) {
      loading = true;
      notifyListeners();

      await getDataReverse();
      loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> refresh() async {
    data.clear();
    positionJumpLock = false;
    limit = pagination;
    offset = 0;
    await getData();
    return data;
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

  Future<void> getDataReverse() async {
    try {
      final fetch = await _repository.fetchDataReverse(limit: limit, offset: offset);

      // 読み込んだ分jumpして見た目が変化しないようにする
      logicalZeroPosition = fetch.length;
      // ↓だと毎回初期値に戻ってしまう
      // logicalZeroPosition += fetch.length;

      data = fetch + data;
      limit += pagination;
      offset += pagination;
    } catch (err) {
    } finally {
      notifyListeners();
    }
  }

}
