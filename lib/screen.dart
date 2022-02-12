import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'model.dart';

// ignore: must_be_immutable
class LoadMoreScreen extends StatelessWidget {
  LoadMoreModel loadMoreModel;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Consumer<LoadMoreModel>(
        builder: (context, model, _) {
          loadMoreModel = model;

          return Scaffold(
            appBar: AppBar(
              title: Text('both load more sample'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    showToast("refresh");
                    await refresh();
                  },
                ),
              ],

            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  // jump buttons
                  jumpControlButtons,
                  jumpLogicalControlButtons,

                  // header
                  Container(
                    width: screenSize.width,
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text("header contents"),
                          margin: EdgeInsets.only(left: 16),
                        ),
                      ],
                    ),
                  ),

                  // scroll view
                  Expanded(
                    child: RefreshIndicator(
                      child: NotificationListener<ScrollNotification>(
                        child: ScrollablePositionedList.builder(
                          itemCount: model.data.length + 1,
                          itemBuilder: (context, index) {

                            if (model.data.isEmpty) {
                              return  Center(child: CircularProgressIndicator());
                            }

                            // display listview data
                            if (index < model.data.length) {
                              final item = model.data[index];
                              return ListTile(
                                title: Text(item),
                              );
                            }

                            // when data length is exceeded
                            return Center(
                              child: Opacity(
                                opacity: model.loading ? 1.0 : 0.0,
                                child: CircularProgressIndicator(),
                              ),
                            );

                          },
                          itemScrollController: loadMoreModel.itemScrollController,
                          itemPositionsListener: loadMoreModel.itemPositionsListener,
                          scrollDirection: Axis.vertical,
                        ),

                        // Get ScrollInfo
                        onNotification: (ScrollNotification scrollInfo) => pushLoadMore(scrollInfo),
                      ),
                      onRefresh: () async {
                        await refresh();
                      },
                    ),
                  ),

                ],
              ),
            ),
          );
        }
    );
  }

  refresh() async {
    await loadMoreModel.refresh();
    jumpTo(0);
  }

  Widget get jumpControlButtons => Row(
    children: <Widget>[
      const Text('jump to (physics)'),
      jumpButton(0),
      jumpButton(5),
      jumpButton(10),
      jumpButton(100),
    ],
  );

  Widget get jumpLogicalControlButtons => Row(
    children: <Widget>[
      const Text('jump to (logical zero position)'),
      jumpButton(loadMoreModel.globalZeroPosition),
    ],
  );

  Widget jumpButton(int value) => GestureDetector(
    key: ValueKey<String>('Jump$value'),
    onTap: () => jumpTo(value),
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('$value')),
  );

  void jumpTo(int index) =>
      loadMoreModel.itemScrollController.jumpTo(index: index);

  bool pushLoadMore(ScrollNotification scrollInfo) {

    // 上下どちらにスクロールしているか判定
    if(scrollInfo.metrics.pixels - loadMoreModel.position >= loadMoreModel.sensitivityFactor){
      // print('Axis Scroll Direction : Up');
      loadMoreModel.position = scrollInfo.metrics.pixels;
      loadMoreModel.positiveScroll = true;
    }
    if (loadMoreModel.position - scrollInfo.metrics.pixels >= loadMoreModel.sensitivityFactor){
      // print('Axis Scroll Direction : Down');
      loadMoreModel.position = scrollInfo.metrics.pixels;
      loadMoreModel.positiveScroll = false;
    }

    // 上下端で追加読み込み (LoadMore)
    if (loadMoreModel.positiveScroll) {
      // positive load more
      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
        loadMoreModel.loadMore();
      }
    } else {
      // negative load more
      if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
        if (!loadMoreModel.positionJumpLock) {
          // 連続で入るので読み込み後jumpするまでLock
          loadMoreModel.positionJumpLock = true;
          loadMoreModel.loadMoreReverse().then((_) {

            showToast("Loaded more items\njump to zero position");

            jumpTo(loadMoreModel.logicalZeroPosition);
            loadMoreModel.positionJumpLock = false;
          });
        }
      }
    }
    return true;
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

}