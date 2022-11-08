import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/comm/asset_manager.dart';
import 'package:smart_diary/db/entity/event.dart';
import 'package:smart_diary/page/event/vm/event_input_vm.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../../comm/dialog.dart';
import '../../../comm/tag_cache.dart';
import '../../../comm/load_asset_widget.dart';

/// 详情页面，根据参数决定是编辑状态还是显示状态
@immutable
class EventDetailPage extends StatefulWidget {
  EventEntity? entity;

  PageState pageState;

  Function? callback;

  EventDetailPage({Key? key, this.entity, this.callback, required this.pageState}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventDetailPageState();
  }
}

class _EventDetailPageState extends State<EventDetailPage> {
  final EventInputVm _vm = EventInputVm();
  List<String> tags = [];

  double bottomHeight = 50;

  @override
  void initState() {
    super.initState();
    _vm.titleController.text = widget.entity?.title ?? "";
    _vm.contentController.text = widget.entity?.content ?? "";
    _vm.tag = widget.entity?.tag ?? '';
    _obtainAssets();

    // 如果传进来的数据，第一步，先锁定为 仅查看模式，点解锁之后才是 编辑模式
    setState(() {
      _vm.pageState = widget.pageState;
    });
  }

  List<Widget> get _assetWidgetList {
    List<Widget> widgetList = [];

    bool needDelete = false;
    double size = 90;
    double roundRadius = 8;
    if (_vm.pageState == PageState.readOnly) {
      needDelete = false;
      size = 150;
      roundRadius = 4;
    } else if (_vm.pageState == PageState.create) {
      needDelete = true;
    } else if (_vm.pageState == PageState.edit) {
      needDelete = true;
    }

    _vm.selectedAssets.asMap().forEach((index, entity) {
      widgetList.add(loadAssetWidget(
          context: context,
          assets: _vm.selectedAssets,
          theme: commThemeColor,
          size: size,
          index: index,
          roundRadius: roundRadius,
          needDelete: needDelete,
          boxFit: BoxFit.fitWidth,
          onDelete: () {
            setState(() {
              _vm.selectedAssets.remove(entity);
            });
          }));
    });

    return widgetList;
  }

  _getAppBar() {
    String title = '';
    bool hasCommit = false;

    if (_vm.pageState == PageState.readOnly) {
      title = '事件查看';
      hasCommit = false;
    } else if (_vm.pageState == PageState.create) {
      title = '事件录入';
      hasCommit = true;
    } else if (_vm.pageState == PageState.edit) {
      title = '事件编辑';
      hasCommit = true;
    }

    return AppBar(
      backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7),
      title: Text(title),
      actions: [
        if (hasCommit) ...[
          TextButton(
            onPressed: commitFunc,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(color: Theme.of(context).buttonColor, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 5)
        ] else ...[
          TextButton(
            onPressed: _gotoEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(color: Theme.of(context).buttonColor, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                '去编辑',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 5)
        ],
      ],
    );
  }

  _gotoEdit() {
    setState(() {
      _vm.pageState = PageState.edit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar(),
        body: ChangeNotifierProvider(
          create: (BuildContext context) => _vm,
          builder: (context, child) {
            return Consumer<EventInputVm>(builder: (BuildContext context, EventInputVm vm, Widget? child) {
              return WillPopScope(
                onWillPop: () {
                  widget.callback?.call();
                  return Future.value(true);
                },
                child: Stack(
                  children: [
                    Container(
                        color: Theme.of(context).primaryColor,
                        height: MediaQuery.of(context).size.height,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                _titleWidget(),
                                Row(children: [_dateWidget(), _tagChooseWidget()]),
                                _contentWidget(),
                                _assetsWidget(),
                                const SizedBox(height: 300),
                              ]),
                            ))),
                    Positioned(bottom: 0, left: 0, right: 0, child: _resSelectedButtons())
                  ],
                ),
              );
            });
          },
        ));
  }

  Widget _tagChooseWidget() {
    bool readOnly = false;
    if (_vm.pageState == PageState.readOnly) {
      readOnly = true;
    } else if (_vm.pageState == PageState.create) {
      readOnly = false;
    } else if (_vm.pageState == PageState.edit) {
      readOnly = false;
    }

    return GestureDetector(
      onTap: () async {
        if (readOnly) return;
        // 弹窗，选择标签, 弹窗中支持创建新标签
        var tag = await showTagChooseDialog(context, _vm.tag);
        if (tag != null && tag.isNotEmpty) {
          _vm.setTag(tag);
        }
      },
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor),
          child: Row(
            children: [
              if (readOnly) ...[
                Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(_vm.tag.isEmpty ? '无标签' : _vm.tag, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white))),
              ] else ...[
                Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Text(_vm.tag.isEmpty ? '选择标签' : _vm.tag, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white))),
                const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.white)
              ],
            ],
          )),
    );
  }

  /// 初始化已有的图
  Future<void> _obtainAssets() async {
    var imgList = widget.entity?.asset;
    if (imgList == null) return;
    for (int i = 0; i < imgList.length; i++) {
      AssetBean e = imgList[i];
      AssetEntity? current = await AssetEntity.fromId(e.assetId ?? '');
      _vm.selectedAssets.add(current ?? const AssetEntity(id: '', width: 0, height: 0, typeInt: 0));
    }
    setState(() {});
  }

  /// 提交
  void commitFunc() {
    EasyLoading.show(status: 'loading');
    // 如果传入了原对象，则视为
    if (widget.entity == null) {
      _vm.insertOne().then((id) {
        EasyLoading.dismiss(animation: true);
        TagCachePool().saveTag(_vm.tag);
        if (id > 0) {
          Navigator.pop(context, true);
          widget.callback?.call();
        }
      });
    } else {
      _vm.updateOne(widget.entity!).then((id) {
        EasyLoading.dismiss(animation: true);
        TagCachePool().saveTag(_vm.tag);
        if (id > 0) {
          Navigator.pop(context, true);
          widget.callback?.call();
        } else {
          showToast('修改失败');
        }
      });
    }
  }

  Widget _titleWidget() {
    bool readOnly = false;
    if (_vm.pageState == PageState.readOnly) {
      readOnly = true;
    } else if (_vm.pageState == PageState.create) {
      readOnly = false;
    } else if (_vm.pageState == PageState.edit) {
      readOnly = false;
    }

    return TextField(
      readOnly: readOnly,
      controller: _vm.titleController,
      style: TextStyle(fontSize: 25, color: Theme.of(context).textTheme.displayLarge!.color),
      cursorColor: Colors.blueGrey,
      decoration: InputDecoration(
          hintText: '请输入标题',
          hintStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
          border: InputBorder.none,
          labelStyle: TextStyle(color: Theme.of(context).buttonColor)),
    );
  }

  Widget _dateWidget() {
    List<String> formats = ['yyyy', '年', 'mm', '月', 'dd', '日', ' ', 'HH', ':', 'nn'];
    DateLocale dateLocale = const SimplifiedChineseDateLocale();

    if (widget.entity == null) {
      return Text(
        '现在是 ${formatDate(DateTime.now(), formats, locale: dateLocale)}',
        style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.displayLarge!.color),
      );
    } else {
      return Text(
        formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity?.date ?? 0), formats, locale: dateLocale),
        style: TextStyle(fontSize: 14, color: Colors.amber.shade400),
      );
    }
  }

  Widget _contentWidget() {
    bool readOnly = false;
    if (_vm.pageState == PageState.readOnly) {
      readOnly = true;
    } else if (_vm.pageState == PageState.create) {
      readOnly = false;
    } else if (_vm.pageState == PageState.edit) {
      readOnly = false;
    }

    return TextField(
      readOnly: readOnly,
      controller: _vm.contentController,
      style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color),
      maxLines: 100,
      minLines: 5,
      cursorColor: Colors.blueGrey,
      decoration: InputDecoration(
        hintText: '请输入内容',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.displayLarge!.color,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _assetsWidget() {
    return Wrap(direction: Axis.horizontal, children: _assetWidgetList);
  }

  Widget _resSelectedButtons() {
    bool readOnly = false;
    if (_vm.pageState == PageState.readOnly) {
      readOnly = true;
    } else if (_vm.pageState == PageState.create) {
      readOnly = false;
    } else if (_vm.pageState == PageState.edit) {
      readOnly = false;
    }

    if (readOnly) {
      return const SizedBox();
    } else {
      return Container(
          height: bottomHeight,
          decoration: BoxDecoration(color: Theme.of(context).buttonColor.withOpacity(0.7), borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(onTap: _chooseAssets, child: Image.asset(AssetManager.png('image'), width: 30)),
            GestureDetector(onTap: _captureAssets, child: Image.asset(AssetManager.png('record_fill'), width: 30)),
            GestureDetector(
                onTap: () => showToast('选择音乐施工中，请期待...', textPadding: const EdgeInsets.all(10)),
                child: Image.asset(AssetManager.png('sound'), width: 30)),
          ]));
    }
  }

  Future<void> _chooseAssets() async {
    if (await checkAlbumPermission() == false) {
      showToast('暂无相册权限,请前往设置开启权限');
      return;
    }

    if (await checkStoragePermission() == false) {
      showToast('暂无内部存储访问权限,请前往设置开启权限');
      return;
    }

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9,
        requestType: RequestType.common,
        selectedAssets: _vm.selectedAssets,
        themeColor: Colors.green,
        textDelegate: const AssetPickerTextDelegate(),
      ),
    );

    if (result == null || result.isEmpty) {
      // showToast('没有选择任何视频');
      return;
    }

    setState(() {
      _vm.selectedAssets.clear();
      _vm.selectedAssets.addAll(result);
    });
  }

  Future<bool> checkAlbumPermission() async {
    // 相册权限
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps != PermissionState.authorized && ps != PermissionState.limited) {
      return false;
    }
    return true;
  }

  //判断是否有权限
  Future<bool> checkStoragePermission() async {
    Permission permission = Permission.storage;
    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      return true;
    } else {
      return requestPermission(permission);
    }
  }

  //申请权限
  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    debugPrint('权限状态$status');
    return status.isGranted;
  }

  /// 拍照或者拍摄视频
  Future<void> _captureAssets() async {
    if (await checkAlbumPermission() == false) {
      showToast('暂无相册权限,请前往设置开启权限');
      return;
    }

    final AssetEntity? result = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: const CameraPickerConfig(
          enableRecording: true, // 是否可以录像
          maximumRecordingDuration: Duration(seconds: 15), // 录制视频最长时长
          textDelegate: CameraPickerTextDelegate()),
    );
    if (result == null) {
      // showToast('用户取消拍照');
      return;
    }

    setState(() {
      _vm.selectedAssets.add(result);
    });
  }
}
