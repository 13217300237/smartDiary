import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/page/todo/todo_detail_page.dart';
import 'package:smart_diary/page/todo/vm/todo_main_vm.dart';

import '../../comm/asset_manager.dart';
import '../../comm/const.dart';
import '../../comm/dialog.dart';
import '../../db/entity/todo.dart';
import '../base/loading_view.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TodoPageState();
  }
}

class TodoPageState extends State<TodoPage> {
  final TodoMainVm _vm = TodoMainVm();
  final ScrollController _controller = ScrollController();
  bool _showBackToTop = false;
  double _offsetZ = 300;

  double topOpacity = 1;

  final GlobalKey _topKey = GlobalKey();

  late double oriHeight;

  double? renderHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _vm.queryAllExpiredTodo();
    });

    _vm.checkIfDataNull().then((hasData) {
      _vm.queryAll();
    });

    _controller.addListener(() {
      var d = _controller.offset;

      if (d >= _offsetZ && _showBackToTop == false) {
        setState(() {
          _showBackToTop = true;
        });
      } else if (d < _offsetZ && _showBackToTop == true) {
        setState(() {
          _showBackToTop = false;
        });
      }
    });

    eventBus.on<int>().listen((event) {
      // debugPrint('代办页面收到刷新命令');
      _vm.queryAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (BuildContext context) => _vm,
            child: Consumer<TodoMainVm>(builder: (BuildContext context, TodoMainVm vm, Widget? child) {
              return Stack(
                children: [
                  Column(children: [_tabs(), _mainLayout()]),
                  _actions()
                ],
              );
            })));
  }

  _tabBtnStyle() {
    return ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) {
        return Theme.of(context).buttonColor;
      }
      return Theme.of(context).buttonColor.withOpacity(.5);
    }));
  }

  _tabs() {
    _getTabLineColor(int index) {
      if (_vm.currentIndex == index) {
        return Theme.of(context).textTheme.displayLarge!.color;
      } else {
        return Colors.transparent;
      }
    }

    _tab(String text, int index, VoidCallback callback) {
      return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            ElevatedButton(style: _tabBtnStyle(), onPressed: callback, child: Text(text)),
            Image.asset(AssetManager.png('line'), color: _getTabLineColor(index), width: 40, height: 10, fit: BoxFit.fitWidth)
          ]));
    }

    return Container(
        color: Theme.of(context).primaryColor.withOpacity(.9),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(children: [
            _tab('查看全部', 0, _vm.filterAll),
            _tab('只看未完成', 1, _vm.filterUnDone),
            _tab('只看已完成', 2, _vm.filterDone),
            _tab('只看已过期', 3, _vm.filterExpired),
          ]),
        ));
  }

  _mainLayout() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.only(top: 0, bottom: MediaQuery.of(context).padding.bottom),
          color: Theme.of(context).primaryColor.withOpacity(.9),
          child: LoadingView(
              loadingStatus: _vm.loadingStatus,
              idleWidget: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                        child: Text('从这里开始\n记录第一条代办',
                            style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color, height: 1.5), textAlign: TextAlign.center)),
                  ),
                ),
                GestureDetector(
                    onTap: _goDetail,
                    child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          AssetManager.png('create'),
                          width: 80,
                          color: Theme.of(context).buttonColor,
                        )))
              ]),
              child: GroupListView(
                physics: const ClampingScrollPhysics(),
                controller: _controller,
                sectionsCount: _vm.elements.keys.toList().length,
                countOfItemInSection: (int section) {
                  return _vm.elements.values.toList()[section].length;
                },
                itemBuilder: _itemBuilder,
                groupHeaderBuilder: _groupHeaderBuilder,
                separatorBuilder: (context, index) => const SizedBox(height: 5),
                sectionSeparatorBuilder: (context, section) => const SizedBox(height: 10),
              ))),
    );
  }

  _actions() {
    return Positioned(
      right: 20,
      bottom: 50,
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        if (_showBackToTop) ...[
          FloatingActionButton(
              backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7),
              onPressed: () {
                _controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.ease);
              },
              child: Image.asset(AssetManager.png('arrow_to_top'), color: Colors.white, width: 25)),
          const SizedBox(height: 20)
        ],
        if (_vm.hasData)
          FloatingActionButton(
              backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7),
              onPressed: _goDetail,
              child: Image.asset(AssetManager.png('todo'), width: 25, color: Colors.white))
      ]),
    );
  }

  _goDetail() {
    // 跳转到详情页面
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return TodoDetailPage();
    })).then((value) {
      _vm.queryAll();
      _vm.refreshIndex();
    });
  }

  Widget _groupHeaderBuilder(BuildContext context, int section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Text(
        _vm.elements.keys.toList()[section],
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, IndexPath index) {
    bool isLast = false;
    // 如果它是最后一组的最后一项，那就加个尾巴
    if (index.section == _vm.elements.values.length - 1) {
      var lastIndex = _vm.elements.values.toList()[index.section].length - 1;
      if (index.index == lastIndex) {
        isLast = true;
      }
    }

    // 拿到当前item
    TodoEntity currentItem = _vm.elements.values.toList()[index.section][index.index];
    String heroTag = 'todoCheckBoxTag${currentItem.id}';

    String content = currentItem.content ?? '';

    TextDecoration textDecoration = currentItem.done ? TextDecoration.lineThrough : TextDecoration.none;

    String user = currentItem.toString();

    Color cardBgColor = currentItem.done ? Colors.grey.withOpacity(0.1) : Colors.white;

    if (currentItem.ifExpired) {
      cardBgColor = Colors.grey.withOpacity(0.1).withRed(220);
    }

    Color textColor = currentItem.done ? Colors.black.withOpacity(0.5) : Colors.black;
    Color circleAvatarColor = currentItem.done ? Colors.blueGrey.withOpacity(0.5) : Colors.amber;
    Color checkBoxColor = currentItem.done ? Colors.blue.withOpacity(0.5) : Colors.grey;

    // 左
    Widget leadingWidget = CircleAvatar(
      radius: 14,
      backgroundColor: circleAvatarColor,
      child: Text(
        _vm.getInitials(user),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );

    Widget commMargin = const SizedBox(height: 5);

    Widget timeWidget;
    if (currentItem.modifyTimeStr != currentItem.recordTimeStr) {
      timeWidget = Text('最近修改 ${currentItem.modifyTimeStr}', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 12));
    } else {
      timeWidget = Text('录入时间 ${currentItem.recordTimeStr}', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 12));
    }

    // 中
    Widget contentWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      commMargin,
      SizedBox(
          width: 200,
          child: Text(content,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                decoration: textDecoration,
                color: textColor,
              ))),
      commMargin,
      commMargin,
      timeWidget,
      commMargin,
      if (currentItem.noticeTimeStr.isNotEmpty) ...[
        Text('提醒时间 ${currentItem.noticeTimeStr}', style: TextStyle(color: Theme.of(context).buttonColor.withBlue(100).withGreen(10), fontSize: 12))
      ],
      commMargin,
    ]);

    Widget tailWidget = Hero(
        tag: heroTag,
        child: Checkbox(
          onChanged: (value) {
            if (mounted) {
              setState(() {
                currentItem.done = (value ?? false);
                _vm.postUpdate(currentItem).then((value) {
                  if (value == true) {
                    _vm.checkIfDataNull();
                    // _vm.queryByIndex();
                  }
                });
              });
            }
          },
          activeColor: checkBoxColor,
          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            } else {
              return Colors.black.withOpacity(0.4);
            }
          }),
          checkColor: Colors.white,
          overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.black;
            } else {
              return Colors.grey;
            }
          }),
          value: currentItem.done,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(9))),
        ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          InkWell(
            onLongPress: () {
              showDeleteDialog(context, currentItem.id ?? 0, (id) async {
                bool deleteSucc = await _vm.deleteById(id);
                if (deleteSucc == true) {
                  _vm.checkIfDataNull();
                  _vm.queryAll();
                }
              });
            },
            onTap: () {
              // 跳转到详情页面
              Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
                return TodoDetailPage(entity: currentItem);
              })).then((value) {
                _vm.queryAll();
              });
            },
            child: Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              color: cardBgColor,
              borderOnForeground: false,
              shadowColor: Colors.black.withOpacity(1.0),
              elevation: 1.5,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      leadingWidget,
                      contentWidget,
                      tailWidget,
                    ]),
                  ),
                  if (currentItem.ifExpired)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Image.asset(
                        AssetManager.png('expired'),
                        width: 60,
                        color: Colors.white,
                      ),
                    )
                ],
              ),
            ),
          ),
          if (isLast) ...[
            const SizedBox(height: 120),
            Image.asset(AssetManager.png('null'), color: Theme.of(context).buttonColor.withOpacity(.6), width: 100),
            const SizedBox(height: 20),
            Center(
              child: Text('没有更多了', style: TextStyle(fontSize: 20, color: Theme.of(context).buttonColor)),
            ),
            const SizedBox(height: 40),
          ]
        ],
      ),
    );
  }
}
