import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/comm/app_info_provider.dart';
import 'package:smart_diary/comm/asset_manager.dart';
import 'package:smart_diary/comm/tag_cache.dart';
import 'package:smart_diary/db/db_core.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../../comm/const.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: MediaQuery.of(context).padding.bottom),
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                Image(image: AssetImage(AssetManager.png('diary')), width: 120.0),
                Text('版本号: 1.0.0', style: TextStyle(color: Theme.of(context).buttonColor.withGreen(100), fontSize: 20)),
                const SizedBox(height: 20),
                Card(
                    margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                    color: Theme.of(context).primaryColor.withOpacity(.2),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                    child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 15, top: 15, bottom: 15),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _menuItemDayNightSwitch(
                              text: '黑夜模式',
                              context: context,
                              asset: AssetManager.png('day_night'),
                              onSwitch: (v) {
                                Provider.of<AppInfoProvider>(context, listen: false).setDayNightStyle(v ? DayNightStyle.night : DayNightStyle.day);
                              }),
                          _menuItemFont(text: '字体切换', context: context, asset: AssetManager.png('font'), fontNameList: [
                            FontData(defaultFontFamily, '默认'),
                            FontData(alimamaFontFamily, '阿里妈妈'),
                            FontData(TsangerYuYangTFontFamily, '渔洋'),
                            FontData(zcool, 'zcool'),
                          ]),
                          _menuItemColor(text: '色调切换', context: context, asset: AssetManager.png('style'), colorDataList: [
                            ColorData(Colors.green, '绿色'),
                            ColorData(Colors.blue, '蓝色'),
                            ColorData(Colors.orange, '橙色'),
                            ColorData(Colors.redAccent, '红色'),
                          ]),
                          _menuItem(
                              text: '应用数据库',
                              context: context,
                              asset: AssetManager.png('db'),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const DatabaseList()));
                              }),
                          _menuItem(
                              text: '清除数据',
                              context: context,
                              asset: AssetManager.png('clean_cache'),
                              onTap: () async {
                                bool? res = await showClearDataDialog();
                                if (res == true) {
                                  _clearData();
                                  eventBus.fire(1);
                                }
                              }),
                          _menuItem(
                              text: '清除数据并加载测试数据',
                              context: context,
                              asset: AssetManager.png('clean_cache'),
                              onTap: () async {
                                bool? res = await showClearDataDialog(text: '即将清除 事件，代办以及关于TA 的所有数据,并加载测试数据，继续吗？');
                                if (res == true) {
                                  _clearData();
                                  await DbCore.initTestData();
                                  eventBus.fire(1);
                                }
                              }),
                          _menuItem(
                              text: '打开设置',
                              context: context,
                              asset: AssetManager.png('setting'),
                              onTap: () {
                                openAppSettings();
                              }),
                        ])))
              ]),
            )));
  }

  _clearData() async {
    // SP清空
    // db清空
    EasyLoading.show(status: '正在清除数据');
    await DbCore.clearData();
    await TagCachePool().clear();
    EasyLoading.dismiss();
    showToast('清空成功~');
  }

  Future<bool?> showClearDataDialog({String text = '即将清除 事件，代办以及关于TA 的所有数据，继续吗？'}) async {
    return await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(text, style: const TextStyle(color: Colors.red)),
            actions: [
              TextButton(
                child: Text("再考虑一下", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor.withRed(100).withGreen(100))),
              )
            ],
          );
        });
  }

  Widget _menuItem({required String text, required BuildContext context, required String asset, Function? onTap}) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(children: [
            Image(image: AssetImage(asset), width: 30.0, color: Theme.of(context).textTheme.displayLarge!.color),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.displayLarge!.color)),
          ])),
    );
  }

  Widget _menuItemDayNightSwitch({required String text, required BuildContext context, required String asset, Function(bool v)? onSwitch}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(children: [
          Image(image: AssetImage(asset), width: 30.0, color: Theme.of(context).textTheme.displayLarge!.color),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color)),
          const Spacer(),
          Switch(
              activeColor: Theme.of(context).buttonColor,
              value: AppInfoProvider().getIfNightStyle,
              onChanged: (v) {
                onSwitch?.call(v);
                setState(() {});
              })
        ]));
  }

  String _fontGroupValue = AppInfoProvider().fontFamily;

  Widget _menuItemFont({required String text, required BuildContext context, required String asset, required List<FontData> fontNameList}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Row(children: [
              Image(image: AssetImage(asset), width: 30.0, color: Theme.of(context).textTheme.displayLarge!.color),
              const SizedBox(width: 10),
              Text(text, style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color)),
              const Spacer(),
            ]),
            Column(
                children: fontNameList.map((e) {
              return Row(children: [
                const SizedBox(width: 20),
                Radio(
                    value: e.fontFamily,
                    activeColor: Theme.of(context).textTheme.displayLarge!.color,
                    groupValue: _fontGroupValue,
                    onChanged: (String? v) {
                      setState(() {
                        _fontGroupValue = v ?? '';
                      });
                      Provider.of<AppInfoProvider>(context, listen: false).setFontFamily(_fontGroupValue);
                    }),
                Text(e.fontName, style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color, fontFamily: e.fontFamily)),
              ]);
            }).toList()),
          ],
        ));
  }

  int _colorGroupValue = AppInfoProvider().mainColor.value;

  Widget _menuItemColor({required String text, required BuildContext context, required String asset, required List<ColorData> colorDataList}) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(children: [
          Row(children: [
            Image(image: AssetImage(asset), width: 30.0, color: Theme.of(context).textTheme.displayLarge!.color),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color)),
            const Spacer(),
          ]),
          Column(
              children: colorDataList.map((e) {
            return Row(children: [
              const SizedBox(width: 20),
              Radio(
                  value: e.color.value,
                  activeColor: Theme.of(context).textTheme.displayLarge!.color,
                  groupValue: _colorGroupValue,
                  onChanged: (int? v) {
                    setState(() {
                      _colorGroupValue = v ?? 0xffffff;
                    });
                    Provider.of<AppInfoProvider>(context, listen: false).setMainColor(_colorGroupValue);
                  }),
              Text(e.colorName, style: TextStyle(fontSize: 18, color: e.color))
            ]);
          }).toList())
        ]));
  }
}

class FontData {
  String fontFamily;
  String fontName;

  FontData(this.fontFamily, this.fontName);
}

class ColorData {
  Color color;
  String colorName;

  ColorData(this.color, this.colorName);
}
