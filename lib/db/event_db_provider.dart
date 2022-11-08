import 'package:date_format/date_format.dart';
import 'package:smart_diary/db/entity/res.dart';

import 'base/base_provider.dart';
import 'comm.dart';
import 'db_core.dart';
import 'entity/event.dart';

class EventDbProvider extends BaseDbProvider<EventEntity> {
  @override
  String get tableName => tableEvent;

  @override
  EventEntity get t => EventEntity();

  @override
  List<String> get columns => [
        columnEventPrimaryId,
        columnEventDate,
        columnEventDay,
        columnEventTitle,
        columnEventContent,
      ];

  @override
  String get columnPrimaryId => columnEventPrimaryId;

  @override
  Future<int> insertOne(EventEntity t) async {
    int eventId = await super.insertOne(t);
    if (eventId == 0) return -1; // -1表示插入异常

    List<AssetBean> resList = t.asset ?? [];
    for (var e in resList) {
      int resId = await DbCore.db.insert(
          tableRes,
          ResEntity(
            assetId: e.assetId,
            type: e.assetTypeIndex ?? 0,
            eventId: eventId,
            filePath: e.filePath,
            thumb: e.thumbPath,
            imgWidth: e.imgWidth,
            imgHeight: e.imgHeight,
          ).toJson());
      if (resId == 0) return -1;
    }

    return 1;
  }

  Future<List<EventEntity>> queryByCondition({String? orderColumn, String? condition}) async {
    List<EventEntity> listEntity = [];
    List<Map<String, dynamic>> list;

    if (condition != null && condition.isNotEmpty) {
      list = await DbCore.db
          .query(tableName, orderBy: orderColumn, where: '$columnEventTitle like "%$condition%" or $columnEventContent like "%$condition%"');
    } else {
      list = await DbCore.db.query(tableName, orderBy: orderColumn);
    }

    for (var e in list) {
      listEntity.add(t.fromJson(e));
    }
    return listEntity;
  }

  /// 联合查询，找出所有事件字段，包括图片
  Future<List<EventEntity>> queryAllCompile({String? yearMonth, String? condition}) async {
    // 第一步查出所有的事件，第二步，查出所有的图片，在本地进行组装
    List<EventEntity> listEvent = await queryByCondition(orderColumn: columnEventDate, condition: condition);

    List<ResEntity> listResEntity = [];
    List<Map<String, dynamic>> list = await DbCore.db.query(tableRes);
    for (var e in list) {
      listResEntity.add(ResEntity().fromJson(e));
    }

    // 现在的到了两个列表，然后进行组装
    for (var e in listEvent) {
      for (var r in listResEntity) {
        if (e.id == r.eventId) {
          e.asset ??= <AssetBean>[];
          e.asset!.add(AssetBean(
            assetId: r.assetId,
            assetTypeIndex: r.type,
            filePath: r.filePath,
            thumbPath: r.thumb,
            imgHeight: r.imgHeight,
            imgWidth: r.imgWidth,
          ));
        }
      }
    }

    if (yearMonth == null) {
      return listEvent.reversed.toList();
    }

    // 过滤指定日期在年月之内的
    return listEvent.where((e) => getDateYearMonth(e.date ?? 0) == yearMonth).toList().reversed.toList();
  }

  String getDateYearMonth(int date) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(date), ['yyyy', '年', 'mm', '月'], locale: const SimplifiedChineseDateLocale());
  }

  @override
  Future<int> update(EventEntity t) async {
    // 由于涉及到多表的查询，所以要针对图片进行单独更新
    // 先把本体更新了
    int eventUpdateRes = await super.update(t);
    if (eventUpdateRes < 0) {
      return -1;
    }

    DbCore.db.delete(tableRes, where: 'eventId=?', whereArgs: ['${t.id}']);

    t.asset?.forEach((e) async {
      await DbCore.db.insert(
          tableRes,
          ResEntity(
                  assetId: e.assetId,
                  type: e.assetTypeIndex,
                  eventId: t.id,
                  filePath: e.filePath,
                  thumb: e.thumbPath,
                  imgWidth: e.imgWidth,
                  imgHeight: e.imgHeight)
              .toJson());
    });

    return 1;
  }
}
