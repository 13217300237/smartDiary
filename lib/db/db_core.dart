import 'package:flutter/cupertino.dart';
import 'package:smart_diary/comm/const.dart';
import 'package:smart_diary/comm/time.dart';
import 'package:smart_diary/db/about_the_one_db_provider.dart';
import 'package:smart_diary/db/entity/event.dart';
import 'package:smart_diary/db/entity/the_one_topic.dart';
import 'package:smart_diary/db/entity/todo.dart';
import 'package:smart_diary/db/event_db_provider.dart';
import 'package:smart_diary/db/todo_db_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'comm.dart';
import 'entity/the_one.dart';

class DbCore {
  static Database? _db;

  static Database get db => _db!;

  static Future open() async {
    _db = await openDatabase(dbName, version: dbVersion, onCreate: (Database db, int version) async {
      await initDbTables(db);
    });
  }

  static Future clearData() async {
    await db.delete(tableEvent);
    await db.delete(tableRes);
    await db.delete(tableTodo);
    await db.delete(tableAboutTheOne);
    await db.delete(tableAboutTheOneTopic);
  }

  static Future initDbTables(Database db) async {
    await db.execute('''
create table $tableEvent ( 
  $columnEventPrimaryId integer primary key autoincrement, 
  $columnEventContent text not null,
  $columnEventTitle text not null,
  $columnEventDate int not null,
  $columnEventDay text not null,
  $columnEventTag text not null,
  $columnEventLevel int not null
  )
''');
    await db.execute('''
      create table $tableRes ( 
  $columnResId integer primary key autoincrement, 
  $columnFilePath text not null,
  $columnResAssetId text not null,
  $columnResType int not null,
  $columnResThumb String,
  $columnEventId int not null,
  $columnResImageWidth int,
  $columnResImageHeight int
  )
      ''');

    await db.execute('''
      create table $tableTodo ( 
  $columnTodoId integer primary key autoincrement, 
  $columnTodoTypeName text not null, 
  $columnTodoContent text not null, 
  $columnTodoRecordTime int not null,
  $columnTodoModifyTime int,
  $columnTodoNoticeTime int,
  $columnTodoIfDone int not null
  )
      ''');

    await db.execute('''
      create table $tableAboutTheOne ( 
  $columnAboutTheOneId integer primary key autoincrement, 
  $columnAboutTheOneName text not null 
  )
      ''');

    await db.execute('''
      create table $tableAboutTheOneTopic ( 
  $columnAboutTheOneTopicId integer primary key autoincrement, 
  $columnAboutTheOneTopicContent text not null, 
  $columnAboutTheOneTopicColor int not null,
  $columnTheOneId int not null
  )
      ''');
  }

  static Future<void> _initEventData() async {
    int date = DateTime.now().millisecondsSinceEpoch;
    EventDbProvider eventProvider = EventDbProvider();

    debugPrint('执行1类事件的插入');
    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(EventEntity(title: '测试事件1类标题-$i', content: '测试事件1类内容-$i', date: date, day: getWeekDay(date), tag: '1类', level: 0));
    }

    debugPrint('执行2类事件的插入');
    date = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(EventEntity(title: '测试事件2类标题-$i', content: '测试事件2类内容-$i', date: date, day: getWeekDay(date), tag: '2类', level: 0));
    }

    debugPrint('执行3类事件的插入');
    date = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(EventEntity(title: '测试事件3类标题-$i', content: '测试事件3类内容-$i', date: date, day: getWeekDay(date), tag: '3类', level: 0));
    }

    debugPrint('执行4类事件的插入');
    date = DateTime.now().subtract(const Duration(days: 365)).millisecondsSinceEpoch;
    for (int i = 0; i < 10; i++) {
      await eventProvider
          .insertOne(EventEntity(title: '测试事件4类标题-$i', content: '测试事件4类内容-$i', date: date, day: getWeekDay(date), tag: '4类', level: 0));
    }

    debugPrint('执行事件的插入完毕');

    return Future.value();
  }

  static Future<void> _initTodoData() async {
    TodoDbProvider eventProvider = TodoDbProvider();

    int date = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;
    int noticeTime = DateTime.now().add(const Duration(days: 2)).millisecondsSinceEpoch;

    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(TodoEntity(typeName: '核酸', content: '记得做核酸$i，明天要回家', recordTime: date, modifyTime: date, noticeTime: noticeTime, ifDone: 0));
    }

    date = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    noticeTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(TodoEntity(typeName: '学习', content: '记得学习Flutter $i', recordTime: date, modifyTime: date, noticeTime: noticeTime, ifDone: 0));
    }

    date = DateTime.now().subtract(const Duration(days: 3)).millisecondsSinceEpoch;
    noticeTime = DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch;

    for (int i = 0; i < 5; i++) {
      await eventProvider
          .insertOne(TodoEntity(typeName: '买菜', content: '记得买菜Flutter $i', recordTime: date, modifyTime: date, noticeTime: noticeTime, ifDone: 0));
    }

    return;
  }

  static Future<void> _initAboutTheOneData() async {
    AboutTheOneDbProvider aboutTheOneDbProvider = AboutTheOneDbProvider();

    for (int i = 0; i < 5; i++) {
      TheOne t = TheOne(name: '话题点$i');
      t.topList = [];
      for (int j = 0; j < 18; j++) {
        t.topList!.add(TheOneTopic(content: '关键词$j', color: availableColors[j % 8].value));
      }
      await aboutTheOneDbProvider.insertOne(t);
    }

    return;
  }

  /// 首次运行时，添加测试数据
  static Future<void> initTestData() async {
    await _initEventData();
    await _initTodoData();
    await _initAboutTheOneData();
  }

  Future close() async => DbCore.db.close();

  static DateTime _changeTimeDate(time) {
    ///如果传进来的是字符串 13/16位 而且不包含-
    DateTime dateTime = DateTime.now();
    if (time is String) {
      if ((time.length == 13 || time.length == 16) && !time.contains("-")) {
        dateTime = timestampToDate(int.parse(time));
      } else {
        dateTime = DateTime.parse(time);
      }
    } else if (time is int) {
      dateTime = timestampToDate(time);
    }
    return dateTime;
  }

  static DateTime timestampToDate(int timestamp) {
    DateTime dateTime = DateTime.now();

    ///如果是十三位时间戳返回这个
    if (timestamp.toString().length == 13) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp.toString().length == 16) {
      ///如果是十六位时间戳
      dateTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
    }
    return dateTime;
  }
}
