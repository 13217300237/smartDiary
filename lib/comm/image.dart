
import 'package:flutter/cupertino.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../db/entity/event.dart';
import '../widget/load_asset_widget.dart';
import 'asset_entity_cache.dart';

BoxFit getBoxFit(int? width, int? height) {
  if ((width ?? 0) >= (height ?? 0)) {
    return BoxFit.fitHeight;
  } else {
    return BoxFit.fitWidth;
  }
}

List<AssetEntity> assetEntityList = [];
final AssetEntityCachePool _cachePool = AssetEntityCachePool();

preview(int index, EventEntity entity,BuildContext context) async {
  assetEntityList.clear();
  for (AssetBean e in entity.asset ?? []) {
    if (e.assetId != null && e.assetId!.isNotEmpty) {
      AssetEntity? cacheEntity = _cachePool.get(e.assetId!);

      if (cacheEntity == null) {
        var temp = (await AssetEntity.fromId(e.assetId ?? '')) ?? const AssetEntity(id: '0', typeInt: 0, width: 0, height: 0);
        _cachePool.put(e.assetId!, temp);
        assetEntityList.add(temp);
      } else {
        assetEntityList.add(cacheEntity);
      }
    }
  }

  AssetPickerViewer.pushToViewer(
    context,
    currentIndex: index,
    previewAssets: assetEntityList,
    themeData: AssetPicker.themeData(commThemeColor),
  );
}
