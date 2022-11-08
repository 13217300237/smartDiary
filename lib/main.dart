import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'comm/app_info_provider.dart';
import 'comm/const.dart';
import 'comm/tag_cache.dart';
import 'db/db_core.dart';
import 'page/main_page.dart';

/// 入口函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 为了提高图片item在列表中快速滑动时重新加载的流畅度
  PaintingBinding.instance.imageCache.maximumSize = 10000; // 2000 entries
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20; //
  AppInfoProvider().init();
  await initDb();
  await TagCachePool().initCache();
  runApp(const MyApp());
  // configLoading();
}

Future initDb() async {
  // 初始化DB
  await DbCore.open();
  // 初始化测试数据
  SharedPreferences sp = await SharedPreferences.getInstance();
  bool? s = sp.getBool(firstTimeRunningTag) ?? false;
  if (s == false) {
    await sp.setBool(firstTimeRunningTag, true);
    // await DbCore.initTestData();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AppInfoProvider())],
      child: Consumer<AppInfoProvider>(
        builder: (context, v, _) {
          return OKToast(
              child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const MainPage(title: '我的备忘录'),
            builder: EasyLoading.init(),
            theme: ThemeData(
                // 底色
                primaryColor: v.bgColor,
                // 字色
                textSelectionColor: v.textColor,
                // 主色调
                buttonColor: v.mainColor,
                // 字体库
                fontFamily: v.fontFamily,
                // 取消所有的水波纹
                highlightColor: Colors.transparent,
                //取消所有的水波纹
                splashColor: Colors.transparent),
          ));
        },
      ),
    );
  }
}
