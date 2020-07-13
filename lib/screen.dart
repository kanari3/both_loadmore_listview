import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'model.dart';

class LoadMoreScreen extends StatelessWidget {
  GlobalKey<State> key = GlobalKey();
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

                    Fluttertoast.showToast(
                        msg: "refresh",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    await refresh();
                  },
                ),
              ],

            ),
            body: Center(
              child: Column(
                children: <Widget>[

                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          jumpControlButtons,
                        ],
                      ),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          jumpLogicalControlButtons,
                        ],
                      ),
                    ],
                  ),

                  // header
                  Container(
                    width: screenSize.width,
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            child: Text("header contents"),
                            margin: EdgeInsets.only(left: 16)
                        ),
                      ],
                    ),
                  ),
                  // header end

                  Expanded(
                    child: RefreshIndicator(
                      child: NotificationListener<ScrollNotification>(
                        child: ScrollablePositionedList.builder(
                          itemCount: model.data.length + 2,
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
                        onNotification: (ScrollNotification scrollInfo) {

                          // 上下どちらにスクロールしているか判定
                          if(scrollInfo.metrics.pixels - model.position >= model.sensitivityFactor){
                            print('Axis Scroll Direction : Up');
                            model.position = scrollInfo.metrics.pixels;
                            model.positiveScroll = true;
                          }
                          if (model.position - scrollInfo.metrics.pixels >= model.sensitivityFactor){
                            print('Axis Scroll Direction : Down');
                            model.position = scrollInfo.metrics.pixels;
                            model.positiveScroll = false;
                          }

                          // 上下端で追加読み込み (LoadMore)
                          if (model.positiveScroll) {
                            // positive load more
                            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              model.loadMore();
                            }
                          } else {
                            // negative load more
                            if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                              if (!model.positionJumpLock) {
                                // 連続で入るので読み込み後jumpするまでLock
                                model.positionJumpLock = true;
                                model.loadMoreReverse().then((_) {

                                  Fluttertoast.showToast(
                                      msg: "Loaded more items\njump to zero position",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.grey,
                                      textColor: Colors.white,
                                      fontSize: 14
                                  );

                                  jumpTo(model.logicalZeroPosition);
                                  model.positionJumpLock = false;
                                });
                              }
                            }
                          }
                          return true;
                        },

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
      jumpButton(loadMoreModel.logicalZeroPosition),
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

}