import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:smart_diary/page/todo/vm/todo_input_vm.dart';

import '../../comm/dialog.dart';
import '../../comm/tag_cache.dart';
import '../../comm/time.dart';
import '../../db/entity/todo.dart';

/// 详情页面，根据参数决定是编辑状态还是显示状态
@immutable
class TodoDetailPage extends StatefulWidget {
  TodoEntity? entity;
  String? heroTag;

  Function? callback;

  TodoDetailPage({Key? key, this.entity, this.callback, this.heroTag}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TodoDetailPageState();
  }
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final TodoInputVm _vm = TodoInputVm();

  Color get checkBoxColor => (widget.entity?.done ?? false) ? Theme.of(context).buttonColor.withOpacity(0.5) : Colors.grey;

  double bottomHeight = 50;

  String get getTitle {
    if (widget.entity == null) {
      return '代办录入';
    } else {
      return '代办修改';
    }
  }

  @override
  void initState() {
    super.initState();
    _vm.loadEntity(widget.entity);
    tags.clear();
    _initTag();
  }

  void _initTag() {
    TagCachePool().getTagList.then((tagList) {
      setState(() {
        tags = tagList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7), title: Text(getTitle), actions: [
          TextButton(
              onPressed: () {
                _commit().then((res) {
                  if (res == false) {
                  } else {
                    TagCachePool().saveTag(_vm.tag).then((b) {
                      if (b == true) {
                        // showToast('保存标签成功');
                      }
                      Navigator.pop(context, res);
                    });
                  }
                });
              },
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(color: Theme.of(context).buttonColor, borderRadius: BorderRadius.circular(8)),
                  child: const Text('确定', style: TextStyle(color: Colors.white)))),
          const SizedBox(width: 5)
        ]),
        body: ChangeNotifierProvider(
          create: (BuildContext context) => _vm,
          child: Consumer<TodoInputVm>(builder: (BuildContext context, TodoInputVm value, Widget? child) {
            return WillPopScope(
                onWillPop: () {
                  widget.callback?.call();
                  return Future.value(true);
                },
                child: Stack(children: [
                  Container(
                      color: Theme.of(context).primaryColor,
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              _tagChooseWidget(),
                              _dateWidget(),
                              _contentWidget(),
                            ]),
                          ))),
                  Positioned(bottom: 0, left: 0, right: 0, child: _resSelectedButtons()),
                  Positioned(bottom: 130, right: 20, child: checkedBox())
                ]));
          }),
        ));
  }

  Widget checkedBox() {
    if (widget.entity != null) {
      return Hero(
          tag: widget.heroTag ?? '',
          child: RoundCheckBox(
              size: 65,
              checkedWidget: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
              checkedColor: Theme.of(context).buttonColor,
              uncheckedColor: Colors.white54,
              border: Border.all(color: getCheckBoxBorderColor(), width: 5),
              isChecked: widget.entity?.done ?? false,
              onTap: (selected) {
                widget.entity?.done = selected!;
                setState(() {});
              }));
    } else {
      return const SizedBox();
    }
  }

  getCheckBoxBorderColor() {
    if (widget.entity?.done ?? false) {
      return Theme.of(context).buttonColor.withOpacity(.5);
    } else {
      return const Color(0xFFD1D1D1);
    }
  }

  Widget _tagChooseWidget() {
    return GestureDetector(
      onTap: () async {
        // 弹窗，选择标签, 弹窗中支持创建新标签
        var tag = await showTagChooseDialog(context, _vm.tag);
        if (tag != null && tag.isNotEmpty) {
          _vm.setTag(tag);
        }
      },
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor.withOpacity(.8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _vm.tag.isEmpty ? '请输入或选择类别标签' : _vm.tag,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white,fontSize: 23),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 27, color: Colors.white)
            ],
          )),
    );
  }

  Widget _dateWidget() {
    if (widget.entity == null) {
      return Text(
        '现在是 ${formatDate(DateTime.now(), dateFormatYMDHN, locale: dateLocale)}',
        style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.displayLarge!.color),
      );
    } else {
      return Text(
        '录入时间 ${formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity?.modifyTime ?? 0), dateFormatYMDHN, locale: dateLocale)}',
        style: const TextStyle(fontSize: 14, color: Colors.amber),
      );
    }
  }

  Widget _contentWidget() {
    return TextField(
      controller: _vm.contentController,
      style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.displayLarge!.color),
      maxLines: 100,
      minLines: 5,
      cursorColor: Theme.of(context).buttonColor,
      decoration: InputDecoration(
        hintText: '请输入代办内容',
        hintStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
        border: InputBorder.none,
        labelStyle: const TextStyle(color: Colors.green, fontSize: 30),
      ),
    );
  }

  Widget _resSelectedButtons() {
    return InkWell(
      onTap: () {
        showTimeChooseDialog();
      },
      child: Container(
          height: bottomHeight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: Theme.of(context).buttonColor.withOpacity(0.8)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_clock, color: Colors.white, size: 30),
              const SizedBox(width: 20),
              Text('提醒时间   ${_vm.time}', style: const TextStyle(color: Colors.white)),
            ],
          )),
    );
  }

  void showTimeChooseDialog() {
    DatePicker.showPicker(
      context,
      showTitleActions: true,
      locale: LocaleType.zh,
      pickerModel: DateTimePickerModel(locale: LocaleType.zh),
      onConfirm: (s) {
        setState(() {
          _vm.noticeDateTime = s;
          _vm.time = formatDate(s, dateFormatYMDHN);
        });
        // _vm.initData();
      },
      theme: DatePickerTheme(
        backgroundColor: Theme.of(context).primaryColor,
        itemHeight: 50,
        cancelStyle: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.displayLarge!.color),
        doneStyle: TextStyle(fontSize: 16, color: Theme.of(context).buttonColor),
      ),
    );
  }

  Future<bool> _commit() async {
    if (widget.entity == null) {
      return _vm.postInsert();
    } else {
      return _vm.postUpdate(widget.entity!);
    }
  }
}
