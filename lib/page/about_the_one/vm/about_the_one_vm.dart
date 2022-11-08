import 'package:flutter/cupertino.dart';
import 'package:smart_diary/db/about_the_one_db_provider.dart';
import 'package:smart_diary/db/comm.dart';
import 'package:smart_diary/db/db_core.dart';
import 'package:smart_diary/db/entity/the_one_topic.dart';
import 'package:smart_diary/page/base/loading_view.dart';

import '../../../db/entity/the_one.dart';

class AboutTheOneVm extends ChangeNotifier {
  final AboutTheOneDbProvider _provider = AboutTheOneDbProvider();

  List<TheOne> dataList = [];

  LoadingStatus loadingStatus = LoadingStatus.loading;

  Future<int> insert(String taName) async {
    return await _provider.insertOne(TheOne(name: taName));
  }

  Future<void> update(TheOne theOne) async {
    await _provider.update(theOne);
    queryAll();
  }

  Future<int> delete(TheOne theOne) async {
    int res = await _provider.delete(theOne.id ?? -1);
    if (res > 0) {
      queryAll();
    }
    return res;
  }

  Future<int> deleteTopic(int id) async {
    int res = await _provider.deleteTopic(id);
    if (res > 0) {
      queryAll();
    }
    return res;
  }

  Future<int> updateTopic(TheOneTopic topic) async {
    return await DbCore.db.update(tableAboutTheOneTopic, topic.toJson(), where: '$columnAboutTheOneTopicId = ?', whereArgs: [topic.id]);
  }

  Future<void> queryAll() async {
    loadingStatus = LoadingStatus.loading;
    notifyListeners();

    List<TheOne> s = await _provider.queryAll();
    dataList.clear();
    dataList.addAll(s.reversed.toList());

    if (dataList.isEmpty) {
      loadingStatus = LoadingStatus.loadingSucButEmpty;
    } else {
      loadingStatus = LoadingStatus.loadingSuc;
    }

    notifyListeners();
  }
}
