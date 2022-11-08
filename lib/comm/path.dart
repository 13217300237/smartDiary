
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../db/entity/event.dart';

String getFinalPath(AssetBean e) {
  String finalPath = e.thumbPath ?? '';

  if (e.assetTypeIndex == AssetType.image.index) {
    finalPath = e.filePath ?? '';
  }

  return finalPath;
}
