import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_diary/comm/path.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../db/entity/event.dart';
import 'const.dart';
import 'image.dart';

class AssetManager {
  static const String _assetPrefix = 'assets/image/';

  static String png(String fileName) {
    return '$_assetPrefix$fileName.png';
  }
}


imgAssetWrap(EventEntity entity,BuildContext context) {

  List<Widget> thumbs = [];

  if (entity.asset == null) return Wrap();

  if (entity.asset!.length == 1) {
    var e = entity.asset![0];

    var file = File(getFinalPath(e));
    double maxWidth = 130;
    thumbs.add(GestureDetector(
        onTap: () {
          preview(0, entity, context);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: FadeInImage(
                  image: FileImage(file),
                  placeholder: AssetImage(AssetManager.png('placeholder')),
                  placeholderFit: BoxFit.scaleDown,
                  width: maxWidth,
                  height: maxWidth / e.imgAspect,
                  fit: getBoxFit(e.imgWidth, e.imgHeight)),
            ),
            if (e.assetTypeIndex == AssetType.video.index) ...[
              Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3))),
                  child: Image.asset(
                    AssetManager.png('play_circle'),
                    width: 40,
                    color: Colors.white,
                  ))
            ]
          ],
        )));

    return Wrap(children: thumbs);
  }

  entity.asset?.asMap().forEach((index, e) {
    // 判定当前是不是超过了（assetMaxCount-1）张
    if (thumbs.length < assetMaxCount - 1) {
      thumbs.add(Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.only(left: 0, right: 15, top: 10),
          child: GestureDetector(
            onTap: () async {
              preview(index, entity, context);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: FadeInImage(
                        image: FileImage(File(getFinalPath(e))),
                        placeholder: AssetImage(AssetManager.png('placeholder')),
                        width: 120,
                        height: 120,
                        fit: getBoxFit(e.imgWidth, e.imgHeight))),
                if (e.assetTypeIndex == AssetType.video.index) ...[
                  Container(
                      decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3))),
                      child: Image.asset(
                        AssetManager.png('play_circle'),
                        width: 40,
                        color: Colors.white,
                      ))
                ]
              ],
            ),
          )));
    } else if (thumbs.length == assetMaxCount - 1) {
      thumbs.add(Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.only(left: 0, right: 15, top: 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FadeInImage(
                      image: FileImage(File(getFinalPath(e))),
                      placeholder: AssetImage(AssetManager.png('placeholder')),
                      width: 120,
                      height: 120,
                      fit: BoxFit.fitWidth)),
              Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3))),
                  child: Icon(Icons.add, size: 50, color: Colors.blueGrey.shade200))
            ],
          )));
    } else {
      // 再多的就不显示了
    }
  });

  return Wrap(children: thumbs);
}
