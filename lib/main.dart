import 'package:both_loadmore_listview/screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model.dart';

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
