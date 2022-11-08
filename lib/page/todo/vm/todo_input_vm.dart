import 'package:flutter/cupertino.dart';
import 'package:oktoast/oktoast.dart';
import 'package:smart_diary/db/entity/todo.dart';

import '../../../db/todo_db_provider.dart';

class TodoInputVm extends ChangeNotifier {
  final TodoDbProvider _provider = TodoDbProvider();

  TextEditingController contentController = TextEditingController();

  String time = '-';

  DateTime? noticeDateTime;

  int? get _noticeTime => noticeDateTime?.millisecondsSinceEpoch;

  String get _content => contentController.text;

  String tag = '';

  void setTag(String tag) {
    this.tag = tag;
    notifyListeners();
  }

  bool insertCheck() {
    if (tag.isEmpty) {
      showToast('类别名不能为空');
      return false;
    }
    if (_content.isEmpty) {
      showToast('代办内容不能为空');
      return false;
    }
    return true;
  }

  Future<bool> postInsert() async {
    if (!insertCheck()) {
      return false;
    }

    TodoEntity entity = TodoEntity(
        typeName: tag,
        content: _content,
        recordTime: DateTime.now().millisecondsSinceEpoch,
        modifyTime: DateTime.now().millisecondsSinceEpoch,
        noticeTime: _noticeTime,
        ifDone: 0);
    int insertRes = await _provider.insertOne(entity);
    return insertRes > 0;
  }

  bool updateCheck() {
    return true;
  }

  Future<bool> postUpdate(TodoEntity entity) async {
    if (!updateCheck()) {
      return false;
    }

    entity.typeName = tag;
    entity.content = contentController.text;
    entity.noticeTime = noticeDateTime?.millisecondsSinceEpoch;
    entity.modifyTime = DateTime.now().millisecondsSinceEpoch;

    int c = await _provider.update(entity);
    return c > 0;
  }

  void loadEntity(TodoEntity? entity) {
    if (entity == null) return;
    tag = entity.typeName ?? '';
    contentController.text = entity.content ?? '';
    time = entity.noticeTimeStr;
    noticeDateTime = DateTime.fromMillisecondsSinceEpoch(entity.noticeTime ?? 0);
  }
}
