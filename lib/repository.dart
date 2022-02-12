class LoadMoreRepository {

  Future<List<String>> fetchData({int limit, int offset}) async {
    List<String> data = List.generate(20, (i) => (i + offset + 1).toString());
    await Future.delayed(const Duration(seconds: 1));

    return Future.value(data);
  }

  Future<List<String>> fetchDataReverse({int limit, int offset}) async {
    List<String> data = List.generate(20, (i) => ((i + offset + 1) * -1).toString());
    data = data.reversed.toList();
    await Future.delayed(const Duration(seconds: 1));

    return Future.value(data);
  }

}
