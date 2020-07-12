import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'model.dart';


const numberOfItems = 112;
const minItemHeight = 20.0;
const maxItemHeight = 150.0;
const scrollDuration = Duration(seconds: 2);

class LoadMoreScreen extends StatelessWidget {

  LoadMoreModel loadMoreModel;


  Widget get positionsView => ValueListenableBuilder<Iterable<ItemPosition>>(
    valueListenable: loadMoreModel.itemPositionsListener.itemPositions,
    builder: (context, positions, child) {
      int min;
      int max;
      if (positions.isNotEmpty) {
        // Determine the first visible item by finding the item with the
        // smallest trailing edge that is greater than 0.  i.e. the first
        // item whose trailing edge in visible in the viewport.
        min = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
        position.itemTrailingEdge < min.itemTrailingEdge
            ? position
            : min)
            .index;
        // Determine the last visible item by finding the item with the
        // greatest leading edge that is less than 1.  i.e. the last
        // item whose leading edge in visible in the viewport.
        max = positions
            .where((ItemPosition position) => position.itemLeadingEdge < 1)
            .reduce((ItemPosition max, ItemPosition position) =>
        position.itemLeadingEdge > max.itemLeadingEdge
            ? position
            : max)
            .index;
      }
      return Row(
        children: <Widget>[
          Expanded(child: Text('First Item: ${min ?? ''}')),
          Expanded(child: Text('Last Item: ${max ?? ''}')),
        ],
      );
    },
  );


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

  Widget scrollButton(int value) => GestureDetector(
    key: ValueKey<String>('Scroll$value'),
    onTap: () => scrollTo(value),
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('$value')),
  );

  Widget jumpButton(int value) => GestureDetector(
    key: ValueKey<String>('Jump$value'),
    onTap: () => jumpTo(value),
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('$value')),
  );

  void scrollTo(int index) => loadMoreModel.itemScrollController.scrollTo(
      index: index,
      duration: scrollDuration,
      curve: Curves.easeInOutCubic);

  void jumpTo(int index) =>
      loadMoreModel.itemScrollController.jumpTo(index: index);


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double headerHeight = 60;

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
                    height: headerHeight,
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