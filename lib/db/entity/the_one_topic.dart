import 'package:smart_diary/db/comm.dart';

import '../base/base_entity.dart';

class TheOneTopic extends BaseEntity {
  String? content;
  int? color;
  int? theOneId;

  TheOneTopic({int? id, this.content, this.color, this.theOneId}) : super(id);

  @override
  BaseEntity fromJson(Map<String, dynamic> map) {
    TheOneTopic entity = TheOneTopic();
    entity.id = map[columnAboutTheOneTopicId] as int?;
    entity.content = map[columnAboutTheOneTopicContent] as String?;
    entity.color = map[columnAboutTheOneTopicColor] as int?;
    entity.theOneId = map[columnTheOneId] as int;
    return entity;
  }

  @override
  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data[columnAboutTheOneTopicId] = id;
    data[columnAboutTheOneTopicContent] = content;
    data[columnAboutTheOneTopicColor] = color;
    data[columnTheOneId] = theOneId;
    return data;
  }

  @override
  String toString() {
    return content ?? '';
  }
}
