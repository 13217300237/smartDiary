import 'package:smart_diary/db/comm.dart';
import 'package:smart_diary/db/db_core.dart';

import 'base/base_provider.dart';
import 'entity/todo.dart';

class TodoDbProvider extends BaseDbProvider<TodoEntity> {
  @override
  String get columnPrimaryId => columnTodoId;

  @override
  List<String> get columns => [
        columnTodoId,
        columnTodoTypeName,
        columnTodoContent,
        columnTodoRecordTime,
        columnTodoModifyTime,
        columnTodoNoticeTime,
        columnTodoIfDone,
      ];

  @override
  TodoEntity get t => TodoEntity();

  @override
  String get tableName => tableTodo;

  Future<List<TodoEntity>> queryAllExpiredTodo() async {
    List<TodoEntity> listEntity = [];
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    List<Map<String, dynamic>> list =
        await DbCore.db.query(tableName, orderBy: columnTodoNoticeTime, where: '$columnTodoIfDone=0 and $columnTodoNoticeTime<$currentTime');
    for (var e in list) {
      listEntity.add(t.fromJson(e));
    }
    return listEntity;
  }
}
