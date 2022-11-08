import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/db/entity/the_one_topic.dart';
import 'package:smart_diary/page/about_the_one/vm/about_the_one_vm.dart';
import 'package:smart_diary/page/base/loading_view.dart';

import '../../comm/asset_manager.dart';
import '../../comm/const.dart';
import '../../db/entity/the_one.dart';

class AboutTheOnePage extends StatefulWidget {
  const AboutTheOnePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AboutTheOnePageState();
  }
}

class AboutTheOnePageState extends State<AboutTheOnePage> with SingleTickerProviderStateMixin {
  final AboutTheOneVm _vm = AboutTheOneVm();

  late Animation<double> _fadeAnimation;
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    initAnimator();
    _vm.queryAll();
    eventBus.on<int>().listen((event) {
      // debugPrint('关于TA页面收到刷新命令');
      _vm.queryAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider(
            create: (BuildContext context) => _vm,
            builder: (context, child) {
              return Consumer<AboutTheOneVm>(builder: (context, vm, child) {
                return Scaffold(
                    body: Stack(alignment: Alignment.centerRight, children: [
                  Container(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: MediaQuery.of(context).padding.bottom),
                      color: Theme.of(context).primaryColor,
                      child: NotificationListener(
                        onNotification: (ScrollNotification notification) {
                          if (notification is ScrollStartNotification) {
                            _fadeAnimationController.forward();
                          } else if (notification is ScrollUpdateNotification) {
                          } else if (notification is ScrollEndNotification) {
                            _fadeAnimationController.reverse();
                          }
                          return false;
                        },
                        child: LoadingView(
                          loadingStatus: _vm.loadingStatus,
                          emptyWidget: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text(
                                '记录关于TA的点点滴滴',
                                style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color),
                              )),
                              const SizedBox(height: 10),
                              Center(
                                  child: Text(
                                '点这里开始',
                                style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color),
                              )),
                              GestureDetector(
                                onTap: createData,
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
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, i) {
                              return mainItem(_vm.dataList[i], i == _vm.dataList.length - 1);
                            },
                            itemCount: _vm.dataList.length,
                          ),
                        ),
                      )),
                  if (_vm.dataList.isNotEmpty)
                    Positioned(
                        bottom: 20,
                        right: 10,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ElevatedButton(
                              style: getFloatBtnStyle(),
                              onPressed: createData,
                              child: Image.asset(AssetManager.png('topic'), width: 30, color: Colors.white)),
                        ))
                ]));
              });
            }));
  }

  Future createData() async {
    String? taName = await showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return createAboutTheOneDataDialog();
          });
        });

    if (taName != null) {
      int addRes = await _vm.insert(taName);
      if (addRes > 0) {
        _vm.queryAll();
      }
    }
  }

  final TextEditingController _taController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  Color _topicColor = Colors.red;

  AlertDialog createAboutTheOneDataDialog() {
    _taController.text = '';
    return AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('TA是', style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.displayLarge!.color)),
        titlePadding: const EdgeInsets.all(20),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor.withOpacity(.7)),
          child: TextField(
            controller: _taController,
            cursorColor: Colors.white,
            maxLength: 8,
            style: TextStyle(fontSize: 24, color: Theme.of(context).textTheme.displayLarge!.color),
            decoration: const InputDecoration(border: InputBorder.none, counterStyle: TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ),
        contentPadding: const EdgeInsets.all(10),
        actions: [
          TextButton(
            child: Text("取消", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            onPressed: () {
              if (_taController.text.isEmpty) {
                showToast('您还没输入TA是谁...');
              } else {
                Navigator.of(context).pop(_taController.text);
              }
            },
            child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor.withRed(100).withGreen(50))),
          )
        ]);
  }

  AlertDialog modifyAboutTheOneDataDialog(TheOne t) {
    _taController.text = t.name ?? '';
    return AlertDialog(
        title: Text('TA是', style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.displayLarge!.color)),
        backgroundColor: Theme.of(context).primaryColor,
        titlePadding: const EdgeInsets.all(20),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor.withOpacity(.7)),
          child: TextField(
            controller: _taController,
            cursorColor: Colors.white,
            maxLength: 8,
            style: TextStyle(fontSize: 24, color: Theme.of(context).textTheme.displayLarge!.color),
            decoration: const InputDecoration(border: InputBorder.none, counterStyle: TextStyle(color: Colors.white, fontSize: 17)),
          ),
        ),
        contentPadding: const EdgeInsets.all(10),
        actions: [
          TextButton(
            child: Text("取消", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            onPressed: () {
              if (_taController.text.isEmpty) {
                showToast('您还没输入TA是谁...');
              } else {
                Navigator.of(context).pop(_taController.text);
              }
            },
            child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor.withRed(100).withGreen(100).withRed(100))),
          )
        ]);
  }

  AlertDialog topicDataDialog(BuildContext context, StateSetter setStater, {bool ifNeedDelete = false, TheOneTopic? topicInstance}) {
    return AlertDialog(
        title: Text('关键词', style: TextStyle(fontSize: 28, color: Theme.of(context).textTheme.displayLarge!.color)),
        titlePadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
        contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
        content: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: _topicColor),
            child: TextField(
              controller: _topicController,
              cursorColor: Colors.white,
              maxLength: 20,
              maxLines: 2,
              style: const TextStyle(fontSize: 24, color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, counterStyle: TextStyle(color: Colors.white, fontSize: 17)),
            ),
          ),
          const SizedBox(height: 20),
          Text('选择标记颜色', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 20)),
          const SizedBox(height: 20),
          SizedBox(
              height: 130,
              child: BlockPicker(
                  availableColors: availableColors,
                  onColorChanged: (Color value) {
                    _topicColor = value;
                    setStater(() {});
                  },
                  pickerColor: _topicColor))
        ]),
        contentPadding: const EdgeInsets.all(10),
        actions: [
          if (ifNeedDelete && topicInstance != null)
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteAction(topicInstance);
                },
                child: Text('删除')),
          TextButton(
            child: Text("取消", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            onPressed: () {
              if (_topicController.text.isEmpty) {
                showToast('您还没输入关键词...');
              } else {
                Navigator.of(context).pop(TheOneTopic(content: _topicController.text, color: (_topicColor).value));
              }
            },
            child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor.withRed(100).withGreen(100))),
          )
        ]);
  }

  void initAnimator() {
    _fadeAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    //匀速
    //图片宽高从0变到300
    _fadeAnimation = Tween(begin: 1.0, end: 0.00).animate(_fadeAnimationController);
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

  ButtonStyle getFloatBtnStyle2() {
    return ButtonStyle(
        padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(const EdgeInsets.all(10)),
        shape: ButtonStyleButton.allOrNull<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        backgroundColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
          Color c = Theme.of(context).buttonColor;
          if (states.contains(MaterialState.disabled)) return c.withOpacity(0.12);
          return c.withOpacity(.7);
        }));
  }

  /// 做一个获取随机颜色的函数
  Color getRandomColor() {
    Color color = Colors.black;
    switch (Random().nextInt(3) % 3) {
      case 0:
        color = Colors.lightGreen.withOpacity(0.5);
        break;
      case 1:
        color = Colors.deepOrange.withOpacity(0.5);
        break;
      case 2:
        color = Colors.amber.withOpacity(0.5);
        break;
    }
    return color;
  }

  @override
  void dispose() {
    super.dispose();
    _fadeAnimationController.dispose();
  }

  Widget mainItem(TheOne item, bool ifLast) {
    return Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10, left: 15, right: 15),
        child: Column(children: [
          Card(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              color: Theme.of(context).buttonColor.withOpacity(.1),
              borderOnForeground: false,
              shadowColor: Colors.black.withOpacity(1.0),
              elevation: 1.5,
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Container(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              item.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Theme.of(context).textTheme.displayLarge!.color),
                            )),
                        const Spacer(),
                        GestureDetector(
                          child: Image.asset(
                            AssetManager.png('modify'),
                            width: 30,
                            color: Theme.of(context).buttonColor,
                          ),
                          onTap: () async {
                            String? res = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return modifyAboutTheOneDataDialog(item);
                                });

                            if (res == null || res.isEmpty) {
                              return;
                            }
                            item.name = res;
                            _vm.update(item);
                          },
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          child: Image.asset(
                            AssetManager.png('delete'),
                            width: 30,
                            color: Theme.of(context).buttonColor,
                          ),
                          onTap: () async {
                            bool? res = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  var span1 = TextSpan(text: '您确定要删除 ', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 16));
                                  var span2 = TextSpan(
                                      text: item.name ?? '',
                                      style: TextStyle(color: Theme.of(context).buttonColor.withBlue(29).withRed(20).withGreen(100), fontSize: 18));
                                  var span3 = TextSpan(text: ' 吗?', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 16));

                                  return AlertDialog(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    title: Text.rich(TextSpan(children: [span1, span2, span3])),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    actions: [
                                      TextButton(
                                        child: Text("取消", style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color!.withRed(100))),
                                      )
                                    ],
                                  );
                                });

                            if (res == true) {
                              _vm.delete(item);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(children: (item.topList ?? []).map((e) => getCard(e)).toList()),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      const SizedBox(width: 10),
                      GestureDetector(
                          child: Image.asset(AssetManager.png('create'), width: 30, color: Theme.of(context).buttonColor),
                          onTap: () async {
                            _addTheOneAction(item);
                          })
                    ])
                  ]))),
          if (ifLast) ...[
            const SizedBox(height: 140),
            Image.asset(AssetManager.png('null'), color: Theme.of(context).buttonColor.withOpacity(.6), width: 100),
            const SizedBox(height: 20),
            Center(child: Text('没有更多了', style: TextStyle(fontSize: 20, color: Theme.of(context).buttonColor))),
            const SizedBox(height: 40)
          ]
        ]));
  }

  _addTheOneAction(TheOne item) async {
    _topicController.text = '';
    _topicColor = Colors.red;
    TheOneTopic? res = await showDialog<TheOneTopic>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return topicDataDialog(context, setState);
          });
        });

    // 将这个关键词，增量更新到当前这一条item中去
    if (res == null || res.content!.isEmpty) {
      return;
    }

    item.topList ??= [];
    res.theOneId = item.id;
    item.topList!.add(res);
    _vm.update(item);
  }

  _editTheOneTopicAction(TheOneTopic theOneTopic) async {
    _topicController.text = '${theOneTopic.content}';
    _topicColor = Color(theOneTopic.color!);

    TheOneTopic? res = await showDialog<TheOneTopic>(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return topicDataDialog(context, setState, ifNeedDelete: true, topicInstance: theOneTopic);
          });
        });

    // 将这个关键词，增量更新到当前这一条item中去
    if (res == null || res.content!.isEmpty) {
      return;
    }

    res.id = theOneTopic.id;
    res.theOneId = theOneTopic.theOneId;
    int updateRes = await _vm.updateTopic(res);
    if (updateRes > 0) _vm.queryAll();
  }

  _deleteAction(TheOneTopic theOneTopic) async {
    bool? res = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('确定删除这个关键词么?', style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color!.withGreen(100).withRed(50))),
            backgroundColor: Theme.of(context).primaryColor,
            content: Text('${theOneTopic.content}', style: TextStyle(fontSize: 22, color: Theme.of(context).textTheme.displayLarge!.color)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              TextButton(
                child: const Text("取消", style: TextStyle(fontSize: 18, color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color)),
              )
            ],
          );
        });

    if (res == true) {
      _vm.deleteTopic(theOneTopic.id ?? -1);
    }
  }

  Widget getCard(TheOneTopic theOneTopic) {
    return GestureDetector(
      onLongPress: () async {
        await _editTheOneTopicAction(theOneTopic);
      },
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          color: Color(theOneTopic.color ?? getRandomColor().value),
          borderOnForeground: false,
          shadowColor: Colors.black.withOpacity(1.0),
          elevation: 1.5,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 6),
            child: Text(theOneTopic.content ?? '', style: TextStyle(fontSize: 20, color: Theme.of(context).textTheme.displayLarge!.color)),
          )),
    );
  }
}
