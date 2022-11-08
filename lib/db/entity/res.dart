import '../base/base_entity.dart';
import '../comm.dart';

class ResEntity extends BaseEntity {
  String? assetId;
  String? filePath;
  String? thumb;
  int? type;
  int? eventId; // 外键
  int? imgWidth;
  int? imgHeight;

  ResEntity({
    int? id,
    this.assetId,
    this.type,
    this.eventId,
    this.filePath,
    this.thumb,
    this.imgWidth,
    this.imgHeight,
  }) : super(id);

  @override
  ResEntity fromJson(Map<String, dynamic> map) {
    ResEntity entity = ResEntity();
    entity.id = map[columnResId] as int?;
    entity.assetId = map[columnResAssetId] as String?;
    entity.type = map[columnResType] as int?;
    entity.eventId = map[columnEventId] as int?;
    entity.filePath = map[columnFilePath] as String?;
    entity.thumb = map[columnResThumb] as String?;
    entity.imgHeight = map[columnResImageHeight] as int?;
    entity.imgWidth = map[columnResImageWidth] as int?;
    return entity;
  }

  @override
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map[columnEventPrimaryId] = id;
    map[columnResAssetId] = assetId;
    map[columnResType] = type;
    map[columnEventId] = eventId;
    map[columnFilePath] = filePath;
    map[columnResThumb] = thumb;
    map[columnResImageHeight] = imgHeight;
    map[columnResImageWidth] = imgWidth;
    return map;
  }

  @override
  String toString() {
    return '$assetId||$eventId || $filePath';
  }
}
