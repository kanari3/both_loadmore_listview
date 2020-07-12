import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'model.dart';

class LoadMoreScreen extends StatelessWidget {
  GlobalKey<State> key = new GlobalKey();
  LoadMoreModel loadMoreModel;

  Widget get jumpControlButtons => Row(
    children: <Widget>[
      const Text('jump to'),
      jumpButton(0),
      jumpButton(5),
      jumpButton(10),
      jumpButton(100),
      jumpButton(1000),
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
                  onPressed: () {
                    model.refresh();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.art_track),
                  onPressed: () {
                    model.refresh();
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


                        onNotification: (ScrollNotification scrollInfo) {

                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            model.loadMore();
                            return true;
                          }

                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
                            model.loadMoreReverse();
                            return true;
                          }

                          return false;
                        },

                      ),
                      onRefresh: () async {
                        await model.refresh();
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

}