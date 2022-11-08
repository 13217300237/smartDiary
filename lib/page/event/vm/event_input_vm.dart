import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image/image.dart';
import 'package:oktoast/oktoast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../comm/time.dart';
import '../../../db/entity/event.dart';
import '../../../db/event_db_provider.dart';

enum PageState{
  readOnly,
  edit,
  create
}

class EventInputVm extends ChangeNotifier {
  final EventDbProvider _provider = EventDbProvider();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  PageState pageState = PageState.readOnly;

  String tag = '';

  void setTag(String tag) {
    this.tag = tag;
    notifyListeners();
  }

  final List<AssetEntity> selectedAssets = [];



  bool insertCheck() {
    String title = titleController.text;
    // 输入检查标题和内容必须都不为空
    if (title.isEmpty) {
      showToast('标题必须填写');
      return false;
    }
    return true;
  }

  Future<int> insertOne() async {
    if (insertCheck()) {
      List<Future<AssetBean>> tempImgList = selectedAssets.map((e) async {
        return getAssetBean(e);
      }).toList();

      List<AssetBean> assetBeanList = [];
      for (var e in tempImgList) {
        assetBeanList.add(await e);
      }

      return _provider.insertOne(EventEntity(
          title: titleController.text,
          content: correctContent(),
          date: DateTime.now().millisecondsSinceEpoch,
          day: getWeekDay(DateTime.now().millisecondsSinceEpoch),
          asset: assetBeanList,
          tag: tag,
          level: 0));
    } else {
      return Future.value(0);
    }
  }

  String correctContent() {
    String contentCorrect = contentController.text;
    if (contentCorrect.isEmpty) {
      contentCorrect = '';
    }

    return contentCorrect;
  }

  /// 必须有变动才允许提交
  bool _updateCheck() {
    return true;
  }

  // Future<String?> _compressAndGetFile(File file) async {
  //   var d = await getApplicationDocumentsDirectory();
  //   String thumbPath = '${d.path}/${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000000)}.jpg';
  //
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     file.absolute.path,
  //     thumbPath,
  //     quality: 88,
  //     rotate: 180,
  //   );
  //
  //   return result?.path ?? '';
  // }

  Future<AssetBean> getAssetBean(AssetEntity e) async {
    String? filePath = (await e.file)?.path;
    String? thumbPath;

    var image;
    if (e.type == AssetType.video) {
      // 生成视频的缩略图
      thumbPath = await VideoThumbnail.thumbnailFile(
        video: filePath ?? '',
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 55,
      );

      thumbPath!;
      image = decodeImage(File(thumbPath).readAsBytesSync())!;
      debugPrint('视频缩略图的宽高是：${image.width} ${image.height}');
    } else if (e.type == AssetType.image) {
      filePath!;
      image = decodeImage(File(filePath).readAsBytesSync())!;
      debugPrint('图的宽高是：${image.width} ${image.height}');
    }

    return AssetBean(
        assetId: e.id, assetTypeIndex: e.type.index, filePath: filePath, thumbPath: thumbPath, imgWidth: image.width, imgHeight: image.height);
  }

  Future<int> updateOne(EventEntity e) async {
    if (_updateCheck()) {
      e.title = titleController.text;
      e.content = correctContent();
      e.tag = tag;
      List<AssetBean> imageList = [];
      for (var e in selectedAssets) {
        imageList.add(await getAssetBean(e));
      }

      e.asset = imageList;
      return _provider.update(e);
    }
    return -1;
  }
}
