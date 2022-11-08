import 'package:smart_diary/db/comm.dart';
import 'package:smart_diary/db/entity/the_one_topic.dart';

import 'base/base_provider.dart';
import 'db_core.dart';
import 'entity/the_one.dart';

class AboutTheOneDbProvider extends BaseDbProvider<TheOne> {
  @override
  String get columnPrimaryId => columnAboutTheOneId;

  @override
  List<String> get columns => [
        columnAboutTheOneId,
        columnAboutTheOneName,
      ];

  @override
  TheOne get t => TheOne();

  @override
  String get tableName => tableAboutTheOne;

  @override
  Future<int> insertOne(TheOne t) async {
    int theOneId = await super.insertOne(t);
    if (theOneId == 0) return -1; // -1表示插入异常

    List<TheOneTopic> topicList = t.topList ?? [];
    for (var e in topicList) {
      int resId = await DbCore.db.insert(
          tableAboutTheOneTopic,
          TheOneTopic(
            content: e.content,
            color: e.color,
            theOneId: theOneId,
          ).toJson());
      if (resId == 0) return -1;
    }
    return theOneId;
  }


  @override
  Future<int> update(TheOne t) async {
    int r = await super.update(t);
    if (r < 0) {
      return -1;
    }

    DbCore.db.delete(tableAboutTheOneTopic, where: '$columnTheOneId=?', whereArgs: ['${t.id}']);

    t.topList?.forEach((e) async {
      await DbCore.db.insert(
          tableAboutTheOneTopic,
          TheOneTopic(
            content: e.content,
            color: e.color,
            theOneId: t.id,
          ).toJson());
    });

    return 1;
  }

  @override
  Future<int> delete(int id) async {
    int x = await super.delete(id);
    await DbCore.db.delete(tableAboutTheOneTopic, where: '$columnTheOneId=?', whereArgs: ['$id']);
    return x;
  }

  Future<int> deleteTopic(int id) async {
    int x = await DbCore.db.delete(tableAboutTheOneTopic, where: '$columnAboutTheOneTopicId=?', whereArgs: ['$id']);
    return x;
  }

  @override
  Future<List<TheOne>> queryAll({String? orderColumn}) async {
    // 第一步查出所有的事件，第二步，查出所有的图片，在本地进行组装
    List<TheOne> list = await super.queryAll(orderColumn: columnAboutTheOneId);

    for (var e in list) {
      e.topList ??= [];
      List<Map<String, dynamic>> s = await DbCore.db.query(tableAboutTheOneTopic, where: '$columnTheOneId=?', whereArgs: ['${e.id}']);
      for (var ex in s) {
        e.topList!.add(TheOneTopic().fromJson(ex) as TheOneTopic);
      }
    }

    return list;
  }
}
