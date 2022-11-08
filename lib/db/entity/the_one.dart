import 'package:smart_diary/db/comm.dart';
import 'package:smart_diary/db/entity/the_one_topic.dart';

import '../base/base_entity.dart';

class TheOne extends BaseEntity {
  String? name;

  List<TheOneTopic>? topList;

  TheOne({int? id, this.name, this.topList}) : super(id);

  @override
  BaseEntity fromJson(Map<String, dynamic> map) {
    TheOne entity = TheOne();
    entity.id = map[columnAboutTheOneId] as int?;
    entity.name = map[columnAboutTheOneName] as String?;
    return entity;
  }

  @override
  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data[columnAboutTheOneId] = id;
    data[columnAboutTheOneName] = name;
    return data;
  }
}
