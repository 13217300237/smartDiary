import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_diary/page/about_the_one/about_the_one_page.dart';
import 'package:smart_diary/page/setting/setting_page.dart';
import 'package:smart_diary/page/todo/todo_page.dart';

import '../comm/const.dart';
import '../comm/count.dart';
import 'event/page/event_page.dart';

/// 主界面
class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  String _todoCount = '0';

  double get drawerEdgeDragWidth {
    return MediaQuery.of(context).size.width * 0.2;
  }

  List<Widget> allPages = [const EventPage(), const TodoPage(), const AboutTheOnePage(), const SettingPage()];

  @override
  void initState() {
    super.initState();
    eventBus.on<UndoneExpiredTodoEntity>().listen((event) {
      if (_todoCount != event.countStr) {
        _todoCount = event.countStr;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 我能不能手动触发抽屉的打开关闭？
    return Stack(children: [
      Scaffold(
          endDrawer: null,
          // 是否允许左侧抽屉通过手势拖出
          drawerEnableOpenDragGesture: true,
          // 是否允许右侧抽屉通过手势拖出
          endDrawerEnableOpenDragGesture: false,
          // 允许通过手势从左侧将抽屉拖出，这个值就是设定的宽度边界值
          drawerEdgeDragWidth: drawerEdgeDragWidth,
          // 这个貌似没有什么实际作用
          drawerDragStartBehavior: DragStartBehavior.start,
          // 抽屉展开时遮罩层的颜色
          drawerScrimColor: const Color(0x80cccccc),
          // 左侧抽屉打开关闭的监听事件
          onDrawerChanged: (b) {
            debugPrint('左侧抽屉状态变化:${b ? "打开" : "关闭"}');
          },
          // 右侧抽屉打开关闭的监听事件
          onEndDrawerChanged: (b) {
            debugPrint('右侧抽屉状态变化:${b ? "打开" : "关闭"}');
          },
          body: IndexedStack(
            index: _index,
            children: allPages,
          ),
          // This trailing comma make
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              fixedColor: Theme.of(context).textTheme.displayLarge!.color,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(.6),
              onTap: (i) {
                setState(() {
                  _index = i;
                });
              },
              currentIndex: _index,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "事件",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.star),
                  label: "代办",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.segment),
                  label: "关于TA",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "设置",
                )
              ])),
      if (_todoCount.isNotEmpty && _todoCount != '0')
        Positioned(
            bottom: 25,
            left: 150,
            child: Container(
                width: getBudgetWidth,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                child: Center(
                    child: Text(
                  _todoCount,
                  style: const TextStyle(color: Colors.white),
                ))))
    ]);
  }

  double get getBudgetWidth {
    if (_todoCount.length == 1) {
      return 25;
    } else if (_todoCount.length == 2) {
      return 35;
    } else {
      return 45;
    }
  }

  Widget menuItem(String text, Function onTab) {
    return Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Builder(builder: (context) {
          return GestureDetector(
              onTap: () {
                Scaffold.of(context).closeDrawer();
                onTab();
              },
              child: Text(text,
                  style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).textTheme.displayLarge!.color,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.double,
                  )));
        }));
  }
}
