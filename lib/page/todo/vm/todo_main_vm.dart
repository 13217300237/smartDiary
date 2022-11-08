import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_diary/db/comm.dart';
import 'package:smart_diary/db/entity/todo.dart';

import '../../../comm/const.dart';
import '../../../comm/count.dart';
import '../../../comm/time.dart';
import '../../../db/todo_db_provider.dart';
import '../../base/loading_view.dart';

class TodoMainVm extends ChangeNotifier {
  final TodoDbProvider _provider = TodoDbProvider();

  DateTime _selectedDateTime = DateTime.now();

  bool _hasData = false;

  int currentIndex = 0;

  bool get hasData => _hasData;

  LoadingStatus loadingStatus = LoadingStatus.loading;

  DateTime get selectedDateTime => _selectedDateTime;

  String get selectedDateTimeStr {
    return formatDate(_selectedDateTime, dateFormatYMD);
  }

  final Map<String, List<TodoEntity>> elements = {};

  int get size {
    var vs = elements.values.toList();
    int currentSize = 0;
    vs.map((e) => e.length).toList().forEach((e) {
      currentSize += e;
    });
    return currentSize;
  }

  /// 获取第一个字符作为标题
  String getInitials(String user) {
    if (user.isNotEmpty) {
      return user.substring(0, 1);
    } else {
      return '';
    }
  }

  /// 先建立所有的类别大纲，然后往大纲内添加item
  void _transQueryResIntoGroupedMap(List<TodoEntity> queryRes) {
    elements.clear();
    // 将转化出来的结果按照typeName进行分组显示，就要先把数据分组
    List<String> typeNames = queryRes.map((e) => e.typeName ?? '').toList();

    // 然后把对应组的 entity 插入进去
    for (var e in typeNames) {
      List<TodoEntity> filterByTypeNameList = queryRes.where((e2) {
        return e2.typeName == e;
      }).toList();
      elements[e] = filterByTypeNameList;
    }
  }

  ///在这里把录入日期不在 selectedDateTime当天的，全部忽略
  List<TodoEntity> _filterByDateTime(List<TodoEntity> queryRes) {
    return queryRes.where((e) {
      if (e.recordTime == null || e.recordTime == 0) {
        return false;
      }

      String selectedDateTimeStr = formatDate(_selectedDateTime, dateFormatYMD);
      String recordTimeStr = formatDate(DateTime.fromMillisecondsSinceEpoch(e.recordTime!), dateFormatYMD);

      return selectedDateTimeStr == recordTimeStr;
    }).toList();
  }

  /// 检查事件表中是否存在数据
  Future<bool> checkIfDataNull() async {
    List<TodoEntity> res = await _provider.queryAll();
    _hasData = res.isNotEmpty;
    if (_hasData == false) {
      loadingStatus = LoadingStatus.idle;
    }
    notifyListeners();
    return res.isNotEmpty;
  }

  List<TodoEntity> _filterByIfDone(List<TodoEntity> queryRes, {bool? ifDone}) {
    if (null == ifDone) return queryRes;

    return queryRes.where((e) {
      return e.ifDone == (ifDone ? 1 : 0);
    }).toList();
  }

  refreshIndex() {
    currentIndex = 0;
    notifyListeners();
  }

  Future queryAll({bool? ifDone}) async {
    loadingStatus = LoadingStatus.loading;
    notifyListeners();

    List<TodoEntity> queryRes = await _provider.queryAll(orderColumn: columnTodoRecordTime);
    // queryRes = _filterByDateTime(queryRes.reversed.toList());
    queryRes = _filterByIfDone(queryRes.reversed.toList(), ifDone: ifDone);

    _transQueryResIntoGroupedMap(queryRes);

    // 检测数据，如果有
    if (elements.isNotEmpty) {
      loadingStatus = LoadingStatus.loadingSuc;
    } else {
      if (ifDone != null) {
        loadingStatus = LoadingStatus.loadingSucButEmpty;
      } else {
        loadingStatus = LoadingStatus.idle;
      }
    }

    checkIfDataNull();
    queryAllExpiredTodo();
    notifyListeners();
  }

  void filterData({required DateTime selectedDateTime}) {
    _selectedDateTime = selectedDateTime;
    queryAll();
  }

  Future<bool> postUpdate(TodoEntity entity) async {
    entity.modifyTime = DateTime.now().millisecondsSinceEpoch;
    int c = await _provider.update(entity);
    await queryAllExpiredTodo();
    return c > 0;
  }

  Future<bool> deleteById(int id) async {
    return await _provider.delete(id) > 0;
  }

  Future<int> queryAllExpiredTodo() async {
    var list = await _provider.queryAllExpiredTodo();
    eventBus.fire(UndoneExpiredTodoEntity(list.length));
    return list.length;
  }

  void filterUnDone() async {
    await queryAll(ifDone: false);
    currentIndex = 1;
    notifyListeners();
  }

  void filterDone() async {
    await queryAll(ifDone: true);
    currentIndex = 2;
    notifyListeners();
  }

  void filterAll() async {
    await queryAll();
    currentIndex = 0;
    notifyListeners();
  }

  void filterExpired() async {
    var list = await _provider.queryAllExpiredTodo();
    _transQueryResIntoGroupedMap(list);
    currentIndex = 3;
    notifyListeners();
  }

  void queryByIndex() {
    switch (currentIndex) {
      case 0:
        filterAll();
        break;
      case 1:
        filterUnDone();
        break;
      case 2:
        filterDone();
        break;
      case 3:
        filterExpired();
        break;
    }
  }
}
