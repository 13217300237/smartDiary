import '../base/base_entity.dart';
import '../comm.dart';

class AssetBean {
  String? assetId;
  int? assetTypeIndex;
  String? filePath;
  String? thumbPath;
  String? tag;
  int? level;
  int? imgHeight;
  int? imgWidth;

  double get imgAspect {
    if (imgWidth == null || imgHeight == null) return 1;

    return imgWidth! / imgHeight!;
  }

  AssetBean({this.assetId, this.assetTypeIndex, this.filePath, this.thumbPath, this.tag, this.level, this.imgWidth, this.imgHeight});

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['assetId'] = assetId;
    data['assetTypeIndex'] = assetTypeIndex;
    data['filePath'] = filePath;
    data['thumbPath'] = thumbPath;
    data['tag'] = tag;
    data['level'] = level;
    data['imgHeight'] = imgHeight;
    data['imgWidth'] = imgWidth;

    return data;
  }

  AssetBean fromJson(Map<String, dynamic> json) {
    AssetBean entity = AssetBean();
    entity.assetId = json['assetId'] as String?;
    entity.assetTypeIndex = json['assetTypeIndex'] as int?;
    entity.filePath = json['filePath'] as String?;
    entity.thumbPath = json['thumbPath'] as String?;
    entity.tag = json['tag'] as String?;
    entity.level = json['level'] as int?;
    entity.imgHeight = json['imgHeight'] as int?;
    entity.imgWidth = json['imgWidth'] as int?;

    return entity;
  }
}

class EventEntity extends BaseEntity {
  String? title;
  String? content;
  int? date; // 日期(sqflite不支持date和dateTime，只能用时间戳)
  String? day; // 星期
  String? tag;
  int? level;
  List<AssetBean>? asset; //

  EventEntity({
    int? id,
    this.title,
    this.content,
    this.date,
    this.day,
    this.asset,
    this.tag,
    this.level,
  }) : super(id);

  @override
  EventEntity fromJson(Map<String, dynamic> map) {
    EventEntity entity = EventEntity();
    entity.id = map[columnEventPrimaryId] as int?;
    entity.title = map[columnEventTitle] as String?;
    entity.content = map[columnEventContent] as String?;
    entity.date = map[columnEventDate] as int?;
    entity.day = map[columnEventDay] as String?;
    entity.level = map[columnEventLevel] as int?;
    entity.tag = map[columnEventTag] as String?;

    if (map[columnEventAsset] != null) {
      entity.asset = <AssetBean>[];
      map[columnEventAsset].forEach((v) {
        entity.asset!.add(AssetBean().fromJson(v));
      });
    }

    return entity;
  }

  @override
  Map<String, Object?> toJson() {
    var data = <String, dynamic>{};
    data[columnEventPrimaryId] = id;
    data[columnEventTitle] = title;
    data[columnEventContent] = content;
    data[columnEventDate] = date;
    data[columnEventDay] = day;
    data[columnEventTag] = tag;
    data[columnEventLevel] = level;
    return data;
  }

  @override
  String toString() {
    return '$content';
  }
}
