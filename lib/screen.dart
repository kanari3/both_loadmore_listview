import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

class LoadMoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double headerHeight = 60;


    return Consumer<LoadMoreModel>(
        builder: (context, model, _) {

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
              ],

            ),
            body: Center(
              child: Column(
                children: <Widget>[

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

                  Container(
                    height: screenSize.height - headerHeight - 80 ,
                    child: RefreshIndicator(
                      child: ListView.builder(
                        controller: model.scrollController,
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