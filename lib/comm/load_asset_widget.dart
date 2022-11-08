import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

const Color commThemeColor = Colors.green;

Widget loadAssetWidget({
  required BuildContext context,
  required List<AssetEntity?> assets,
  required int index,
  required Color theme,
  double size = 80,
  double padding = 10,
  double roundRadius = 10,
  Function? onDelete,
  bool needDelete = true,
  BoxFit boxFit = BoxFit.fitWidth
}) {
  List<AssetEntity> realEntity = assets.map((e) {
    if (e == null) {
      return const AssetEntity(id: '', typeInt: 0, width: 0, height: 0);
    } else {
      return e;
    }
  }).toList();

  return GestureDetector(
      onTap: () {
        AssetPickerViewer.pushToViewer(
          context,
          currentIndex: index,
          previewAssets: realEntity,
          themeData: AssetPicker.themeData(theme),
        );
      },
      child: Padding(
          padding: EdgeInsets.all(padding),
          child: Stack(alignment: Alignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(roundRadius),
              child: Image(
                image: AssetEntityImageProvider(realEntity[index]),
                width: size,
                height: size,
                fit: boxFit,
                gaplessPlayback: true,// 有大佬建议说加这个属性可以防止闪烁，我看过了，貌似没啥用
              ),
            ),
            if (needDelete)
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                    onTap: () {
                      assets.removeWhere((e) => e == assets[index]);
                      onDelete?.call();
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3)),
                          color: Colors.green.shade100,
                        ),
                        child: const Icon(Icons.delete, size: 20, color: Colors.black))),
              ),
            if (realEntity[index].type == AssetType.video) ...[
              Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3))),
                  child: const Icon(Icons.play_circle, size: 20, color: Colors.black))
            ],
          ])));
}
