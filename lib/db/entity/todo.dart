import 'package:date_format/date_format.dart';

import '../../comm/time.dart';
import '../base/base_entity.dart';
import '../comm.dart';

class TodoEntity extends BaseEntity {
  String? typeName;
  String? content;
  int? recordTime;
  int? modifyTime;
  int? noticeTime;
  int? ifDone;// 0未完成，1已完成

  bool get done => ifDone == 1;

  set done(bool d) => ifDone = d ? 1 : 0;

  bool get ifExpired {
    if (!done && noticeTime != null && noticeTime! > 0 && DateTime.now().millisecondsSinceEpoch > noticeTime!) {
      return true;
    } else {
      return false;
    }
  }

  String get recordTimeStr {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(recordTime ?? 0), dateFormatYMDHN);
  }

  String get modifyTimeStr {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(modifyTime ?? 0), dateFormatYMDHN);
  }

  String get noticeTimeStr {
    if (noticeTime == null || noticeTime == 0) {
      return '';
    }

    return formatDate(DateTime.fromMillisecondsSinceEpoch(noticeTime ?? 0), dateFormatYMDHN);
  }

  TodoEntity({
    int? id,
    this.typeName,
    this.content,
    this.recordTime,
    this.modifyTime,
    this.noticeTime,
    this.ifDone,
  }) : super(id);

  @override
  TodoEntity fromJson(Map<String, dynamic> map) {
    TodoEntity entity = TodoEntity();
    entity.id = map[columnTodoId] as int?;
    entity.typeName = map[columnTodoTypeName] as String?;
    entity.content = map[columnTodoContent] as String?;
    entity.recordTime = map[columnTodoRecordTime] as int?;
    entity.modifyTime = map[columnTodoModifyTime] as int?;
    entity.noticeTime = map[columnTodoNoticeTime] as int?;
    entity.ifDone = map[columnTodoIfDone] as int?;
    return entity;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map[columnTodoId] = id;
    map[columnTodoTypeName] = typeName;
    map[columnTodoContent] = content;
    map[columnTodoRecordTime] = recordTime;
    map[columnTodoModifyTime] = modifyTime;
    map[columnTodoNoticeTime] = noticeTime;
    map[columnTodoIfDone] = ifDone;
    return map;
  }

  @override
  String toString() {
    return '$content';
  }
}
