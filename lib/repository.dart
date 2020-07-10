class LoadMoreRepository {

  Future<List<String>> fetchData({int limit, int offset}) async {

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