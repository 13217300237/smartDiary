import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_diary/comm/asset_manager.dart';
import 'package:smart_diary/db/entity/event.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../comm/asset_entity_cache.dart';
import '../../../comm/const.dart';
import '../../../comm/dialog.dart';
import '../../../comm/image.dart';
import '../../../comm/path.dart';
import '../../../comm/time.dart';
import '../../../comm/load_asset_widget.dart';
import '../page/event_detail_page.dart';
import '../vm/event_input_vm.dart';
import 'event_card.dart';

class TimelineItemWidget extends StatefulWidget {
  final EventEntity entity;
  final EventEntity? lastEntity;
  final EventEntity? nextEntity;
  final Function? onPopBackCallback;
  final Function(int id)? onDeleteCallback;

  const TimelineItemWidget({Key? key, required this.entity, required this.lastEntity, this.onPopBackCallback, this.onDeleteCallback, this.nextEntity})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TimelineItemWidgetState();
  }
}

class _TimelineItemWidgetState extends State<TimelineItemWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _timelineItem(),
      if (ifShowDate != 0)
        Positioned(
            left: 43.5,
            top: 15,
            child: _Circle(
              color: _circleColor(),
              radius: 8,
              context: context,
            )),
    ]);
  }

  /// 0 不显示date
  /// 1 显示年月日
  /// 2 显示月日
  /// 3 显示日
  /// -1 表示没有上一个，自己就是第一个， 那么要显示年月日
  int get ifShowDate {
    if (widget.lastEntity == null) return -1;

    DateTime date = DateTime.fromMillisecondsSinceEpoch(widget.entity.date!);
    DateTime dateLast = DateTime.fromMillisecondsSinceEpoch(widget.lastEntity!.date!);

    // 分理出两个日期的年月日
    String year = formatDate(date, ['yyyy']);
    String yearLast = formatDate(dateLast, ['yyyy']);

    String month = formatDate(date, ['yyyy', 'mm']);
    String monthLast = formatDate(dateLast, ['yyyy', 'mm']);

    String day = formatDate(date, ['yyyy', 'mm', 'dd']);
    String dayLast = formatDate(dateLast, ['yyyy', 'mm', 'dd']);

    if (year != yearLast) return 1;

    if (month != monthLast) return 2;

    if (day != dayLast) return 3;

    return 0;
  }

  bool get ifShowDatePadding {
    if (widget.nextEntity == null) return true;

    String date = getDateStr(widget.entity.date ?? 0);
    String nextDate = getDateStr(widget.nextEntity!.date ?? 0);

    if (date == nextDate) return false;
    return true;
  }

  Widget _dateWidget() {
    switch (ifShowDate) {
      case 1: // 与上一个相比，年不同
      case -1: // 没有上一个
        String date = getDateStr(widget.entity.date ?? 0);
        String today = getDateStr(DateTime.now().millisecondsSinceEpoch);
        if (date == today) {
          return const SizedBox(width: 36, child: Text('今天', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
        }
        return Column(children: [
          const SizedBox(height: 2),
          SizedBox(
            width: 36,
            child: Text(
              '${formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['yyyy'])}年',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['mm'])}月',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['dd']),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 2),
          Text(widget.entity.day ?? '-', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10, color: Theme.of(context).textSelectionColor))
        ]);
      case 0: // 年月日都相同
        return const SizedBox(width: 36);
      case 2: // 年相同，月不同
        return Column(children: [
          const SizedBox(height: 2),
          SizedBox(
            width: 36,
            child: Text(
              '${formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['mm'])}月',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['dd']),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 2),
          Text(widget.entity.day ?? '-', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10, color: Theme.of(context).textSelectionColor))
        ]);
      case 3: // 年月相同，日不同
        return Column(children: [
          const SizedBox(height: 2),
          SizedBox(
            width: 36,
            child: Text(
              formatDate(DateTime.fromMillisecondsSinceEpoch(widget.entity.date ?? 0), ['dd']),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Theme.of(context).textSelectionColor),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 2),
          Text(widget.entity.day ?? '-', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10, color: Theme.of(context).textSelectionColor))
        ]);
    }

    return Text('${ifShowDate}');
  }

  // 把左侧的日期星期，包含这个圆圈当做一个整体
  Widget _timelineItem() {
    return Column(
      children: [
        Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_dateWidget(), const SizedBox(width: 15), _contentArea()]),
        if (widget.nextEntity == null) ...[
          Image.asset(AssetManager.png('null'), color: Theme.of(context).buttonColor.withOpacity(.6), width: 100),
          const SizedBox(height: 20),
          Center(
            child: Text('没有更多了', style: TextStyle(fontSize: 20, color: Theme.of(context).buttonColor)),
          ),
          const SizedBox(height: 40),
        ]
      ],
    );
  }

  Color _circleColor() {
    // Color color = Colors.black;
    // switch (Random().nextInt(3) % 3) {
    //   case 0:
    //     color = Colors.lightGreen;
    //     break;
    //   case 1:
    //     color = Colors.deepOrange;
    //     break;
    //   case 2:
    //     color = Colors.amber;
    //     break;
    // }
    // return color;

    return Theme.of(context).buttonColor;
  }

  /// 利用Container的边框做分割线
  Widget _contentArea() {
    double bottomMargin = ifShowDatePadding ? 33 : 3;
    return Container(
        padding: EdgeInsets.only(left: 14, bottom: bottomMargin),
        // 仅添加左侧的边
        decoration: BoxDecoration(border: Border(left: BorderSide(width: 2, color: Theme.of(context).buttonColor))),
        child: eventCard(entity: widget.entity, context: context, maxWidth: 230, onDelete: widget.onDeleteCallback));
  }
}

class _Circle extends StatelessWidget {
  /// 圆的半径
  final double radius;
  final Color color;
  final BuildContext context;

  const _Circle({required this.radius, required this.color, required this.context});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.fromRadius(radius), painter: _CirclePainter(color: color, radius: radius, context: context));
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double radius;
  final BuildContext context;

  _CirclePainter({required this.color, required this.radius, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = 5;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);

    var paint2 = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = Theme.of(context).primaryColor
      ..strokeWidth = 5;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius / 2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
