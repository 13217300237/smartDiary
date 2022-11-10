import 'dart:async';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/comm/asset_manager.dart';
import 'package:smart_diary/page/base/loading_view.dart';
import 'package:smart_diary/page/event/page/event_detail_page.dart';
import 'package:smart_diary/page/event/widget/timeline_widget.dart';

import '../../../comm/const.dart';
import '../../../comm/time.dart';
import '../../../comm/time_select_model.dart';
import '../vm/event_input_vm.dart';
import '../vm/event_main_vm.dart';
import 'event_search_page2.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EventPageState();
  }
}

class _EventPageState extends State<EventPage> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final EventMainVm _vm = EventMainVm();

  bool _showAppBar = true;
  bool _showBackToTop = false;
  double _appBarOpt = 1; // 原标题栏的透明度
  final double _offsetZ = 50; // 显示隐藏头部和回到顶部按钮的临界值

  late Animation<double> _fadeAnimation;
  late AnimationController _fadeAnimationController;

  final StreamController<int> _streamController = StreamController.broadcast();
  final ScrollController _controller = ScrollController();

  @override
  bool get wantKeepAlive => true;

  String getDateStr(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time), ['yyyy', '年', 'mm', '月', 'dd', '日'], locale: const SimplifiedChineseDateLocale());
  }

  Color get _textColor => Theme.of(context).textTheme.displayLarge!.color!;

  @override
  void initState() {
    super.initState();

    initAnimator();
    _vm.requestData();

    Timer.periodic(const Duration(minutes: minutesCountToShowJustNow), (timer) {
      checkRefresh();
    });

    eventBus.on<int>().listen((event) {
      _vm.requestData();
    });
  }

  void initAnimator() {
    _fadeAnimationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    //匀速
    _fadeAnimation = Tween(begin: 1.0, end: 0.00).animate(_fadeAnimationController);
  }

  void checkRefresh() {
    var list = _vm.listEventEntity.where((e) {
      DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(e.date ?? 0);
      DateTime nowDateTime = DateTime.now();
      int m = nowDateTime.difference(eventDateTime).inMinutes;
      return m < minutesCountToShowJustNow;
    }).toList();

    if (list.isNotEmpty) {
      setState(() {
        debugPrint('找到发布时间距离当前时间5分钟之内的事件，现在刷新');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fadeAnimationController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用
    return Stack(
      children: [
        Scaffold(
            appBar: _getAppBar(),
            body: ChangeNotifierProvider(
                create: (BuildContext context) => _vm,
                child: Consumer<EventMainVm>(builder: (BuildContext context, EventMainVm vm, Widget? child) {
                  return Container(
                      color: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(children: [
                        _top(),
                        const SizedBox(height: 5),
                        Expanded(
                            child: Stack(alignment: Alignment.centerRight, children: [
                          LoadingView(
                              loadingStatus: _vm.loadingStatus,
                              // 数据为空时的布局
                              emptyWidget: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                        child: Text('从这里开始\n记录生活中有意义的事吧',
                                            style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color, height: 1.5),
                                            textAlign: TextAlign.center)),
                                  ),
                                  GestureDetector(
                                    onTap: createEvent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Image.asset(
                                        AssetManager.png('create'),
                                        width: 80,
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              child: TimelineWidget(
                                  context: context,
                                  controller: _controller,
                                  listEventEntity: _vm.listEventEntity,
                                  onPopBackCallback: () {
                                    _vm.requestData();
                                  },
                                  onScrollEnded: (d) {
                                    // debugPrint('滚动结束-所有悬浮按钮可以出现');
                                    _fadeAnimationController.reverse();
                                  },
                                  onScrollStarted: (d) {
                                    // debugPrint('滚动开始-所有悬浮按钮消失');
                                    _fadeAnimationController.forward();
                                  },
                                  onScrollOffset: (d) {
                                    if (d >= _offsetZ && _showBackToTop == false) {
                                      setState(() {
                                        _showBackToTop = true;
                                      });
                                    } else if (d < _offsetZ && _showBackToTop == true) {
                                      setState(() {
                                        _showBackToTop = false;
                                      });
                                    }

                                    if (d < 0) {
                                      _appBarOpt = 1;
                                    }
                                    if (d >= 0 && d < _offsetZ) {
                                      _appBarOpt = 1 - d / _offsetZ;
                                    } else {
                                      _appBarOpt = 0;
                                    }

                                    setState(() {});

                                    if (d >= _offsetZ && _showAppBar == true) {
                                      setState(() {
                                        _showAppBar = false;
                                      });
                                    } else if (d < _offsetZ && _showAppBar == false) {
                                      setState(() {
                                        _showAppBar = true;
                                      });
                                    }
                                  },
                                  onScrollIndex: (first, last) {
                                    _streamController.add(first);
                                  },
                                  onDeleteCallback: (id) async {
                                    bool deleteSucc = await _vm.deleteById(id);
                                    if (deleteSucc == true) {
                                      _vm.requestData();
                                    }
                                  })),
                          if (_vm.listEventEntity.isNotEmpty) ...[
                            if (_showBackToTop) ...[
                              Positioned(
                                  bottom: 100,
                                  child: FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: ElevatedButton(
                                          style: getFloatBtnStyle(),
                                          onPressed: () {
                                            _controller.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                                          },
                                          child: Image.asset(AssetManager.png('arrow_to_top'), color: Colors.white, width: 30)))),
                              const SizedBox(height: 20)
                            ],
                            Positioned(
                              bottom: 40,
                              child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: ElevatedButton(
                                      style: getFloatBtnStyle(),
                                      onPressed: createEvent,
                                      child: Image.asset(AssetManager.png('event'), color: Colors.white, width: 30))),
                            ),
                          ],
                        ]))
                      ]));
                }))),
        Positioned(
          top: 35,
          right: 15,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ElevatedButton(
              style: getFloatBtnStyle(),
              onPressed: gotoSearch,
              child: Image.asset(AssetManager.png('search'), color: Colors.white, width: 30),
            ),
          ),
        )
      ],
    );
  }

  AppBar? _getAppBar() {
    return _showAppBar ? _appBarWidget() : _emptyAppBarWidget();
  }

  void gotoSearch() {
    Get.to(EventSearchPage2(),transition: Transition.rightToLeft)?.then((value) {
      if (value != null) {
        _vm.requestData();
      }
    });

    // // 跳转到详情页面
    // Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
    //   return const EventSearchPage();
    // })).then((value) {
    //   if (value != null) {
    //     _vm.requestData();
    //   }
    // });
  }

  void createEvent() {
    // 跳转到详情页面
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
      return EventDetailPage(pageState: PageState.create);
    })).then((value) {
      if (value != null) {
        _vm.requestData();
      }
    });
  }

  ButtonStyle getFloatBtnStyle() {
    return ButtonStyle(
        padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(const EdgeInsets.all(10)),
        shape: ButtonStyleButton.allOrNull<OutlinedBorder>(const CircleBorder()),
        backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          Color c = Theme.of(context).buttonColor;
          if (states.contains(MaterialState.disabled)) return c.withOpacity(0.12);
          return c.withOpacity(.7);
        }));
  }

  Widget _datePicker() {
    return GestureDetector(
        onTap: () {
          DatePicker.showPicker(
            context,
            showTitleActions: true,
            locale: LocaleType.zh,
            pickerModel: CustomPicker(locale: LocaleType.zh),
            onConfirm: (s) {
              setState(() {
                _vm.yearMonth = formatDate(s, dateFormatYM);
              });
              _vm.requestData();
            },
            theme: DatePickerTheme(
              backgroundColor: Theme.of(context).primaryColor,
              itemHeight: 50,
              cancelStyle: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.displayLarge!.color),
              doneStyle: TextStyle(fontSize: 16, color: Theme.of(context).buttonColor),
            ),
          );
        },
        child: Opacity(
          opacity: _appBarOpt,
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(' ${_vm.yearMonth} ', style: TextStyle(color: _textColor)),
                  Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RotatedBox(
                        // 旋转角度必须是90度的倍数,填2就是180度
                        quarterTurns: 3,
                        child: Center(
                            child: Opacity(
                                opacity: 1,
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: _textColor,
                                ))),
                      ))
                ]),
          ),
        ));
  }

  Widget _top() {
    if (_vm.listEventEntity.isNotEmpty) {
      return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(children: [
            SizedBox(width: 36.5, child: Text('DATE', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13))),
            const SizedBox(width: 15),
            Container(
                padding: const EdgeInsets.only(left: 18),
                decoration: BoxDecoration(border: Border(left: BorderSide(color: Theme.of(context).buttonColor, width: 2))),
                child: Text('EVENTS', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13)))
          ]));
    } else {
      return const SizedBox();
    }
  }

  _appBarWidget() {
    return AppBar(
        title: Column(children: [
          Text(
            '事件时间轴',
            style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
          ) /*,_datePicker()*/
        ]),
        backgroundColor: Theme.of(context).primaryColor,
        shadowColor: Colors.transparent,
        elevation: 1);
  }

  _emptyAppBarWidget() {
    return AppBar(
      title: StreamBuilder<int>(
          stream: _streamController.stream,
          initialData: 0,
          builder: (context, snap) {
            String dateStr = getDateStr(_vm.listEventEntity[snap.data ?? 0].date ?? 0);
            String day = _vm.listEventEntity[snap.data ?? 0].day ?? '';
            return Text('$dateStr $day', style: TextStyle(fontSize: 20, color: _textColor));
          }),
      backgroundColor: Theme.of(context).primaryColor,
      shadowColor: Colors.transparent,
      elevation: 0,
    );
  }
}
