import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => LoadMoreModel(),
        child: LoadMoreScreen(),
      ),
    );
  }
}

class LoadMoreModel extends ChangeNotifier {

  var _repository = NotificationsRepository();

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

      await getNotifications();
      loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> refresh() async {
    data.clear();
    limit = pagination;
    offset = 0;
    await getNotifications();
    return data;
  }

  Future<void> getNotifications() async {
    try {
      final notify = await _repository.fetchNotifications(limit: limit, offset: offset);
      data += notify;
      limit += pagination;
      offset += pagination;
    } catch (err) {
    } finally {
      notifyListeners();
    }
  }

}

class NotificationsRepository {

  Future<List<String>> fetchNotifications({int limit, int offset}) async {

    List<String> data = [
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "6",
      "7",
      "8",
      "9",
      "10",
      "11",
      "12",
      "13",
      "14",
      "15",
      "16",
      "17",
      "18",
      "19",
      "20",
      "21",
      "22",
      "23",
      "24",
      "25",

    ];

    return Future.delayed(Duration(seconds: 1), () {
      return Future.value(data);
    });
  }

}

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


