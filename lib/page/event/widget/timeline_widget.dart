import 'package:flutter/material.dart';
import 'package:smart_diary/db/entity/event.dart';
import 'package:smart_diary/page/event/widget/timeline_item_widget.dart';

class TimelineWidget extends StatefulWidget {
  final List<EventEntity> listEventEntity;

  final BuildContext context;
  final Function? onPopBackCallback;
  final Function(int id)? onDeleteCallback;
  final Function(double offset) onScrollOffset;
  final Function(double offset)? onScrollEnded;
  final Function(double offset)? onScrollStarted;
  final Function(int first, int last)? onScrollIndex;
  final ScrollController controller;

  const TimelineWidget(
      {Key? key,
      required this.listEventEntity,
      this.onPopBackCallback,
      required this.context,
      required this.onDeleteCallback,
      required this.onScrollOffset,
      required this.controller,
      this.onScrollEnded,
      this.onScrollStarted,
      this.onScrollIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimelineWidgetState();
  }
}

class TimelineWidgetState extends State<TimelineWidget> {
  double paddingTop = 0;

  @override
  void initState() {
    super.initState();
    //监听滚动事件，打印滚动位置
    widget.controller.addListener(() {
      widget.onScrollOffset(widget.controller.offset);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.listEventEntity.isEmpty) ...[
          Expanded(
              child: Center(
                  child: Text(
            '暂无数据',
            style: TextStyle(fontSize: 20, color: Theme.of(context).textSelectionColor),
          )))
        ] else ...[
          myCustomListView()
        ]
      ],
    );
  }

  Widget myCustomListView() {
    return Expanded(
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            widget.onScrollStarted?.call(notification.metrics.pixels);
          } else if (notification is ScrollUpdateNotification) {
            // debugPrint(
            //     '正在滚动...2:当前所在点${notification.metrics.pixels}，总滚动距离${notification.metrics.maxScrollExtent}，当前滚动比例值${notification.metrics.pixels / notification.metrics.maxScrollExtent}');
          } else if (notification is ScrollEndNotification) {
            widget.onScrollEnded?.call(notification.metrics.pixels);
          }
          return false;
        },
        child: ListView.custom(
            cacheExtent: 0.0,
            controller: widget.controller,
            physics: const BouncingScrollPhysics(),
            childrenDelegate: CustomScrollDelegate(
              itemCount: widget.listEventEntity.length,
              scrollCallback: (int firstIndex, int lastIndex) {
                widget.onScrollIndex?.call(firstIndex, lastIndex);
              },
              (context, index) {
                EventEntity current = widget.listEventEntity[index];
                EventEntity? lastEntity = index == 0 ? null : widget.listEventEntity[index - 1];
                EventEntity? nextEntity = index == widget.listEventEntity.length - 1 ? null : widget.listEventEntity[index + 1];

                return TimelineItemWidget(
                  entity: current,
                  lastEntity: lastEntity,
                  nextEntity: nextEntity,
                  onPopBackCallback: widget.onPopBackCallback,
                  onDeleteCallback: widget.onDeleteCallback,
                );
              },
            )),
      ),
    );
  }
}

class CustomScrollDelegate extends SliverChildBuilderDelegate {
  Function(int firstIndex, int lastIndex) scrollCallback;

  CustomScrollDelegate(super.builder, {required int itemCount, required this.scrollCallback}) : super(childCount: itemCount);

  @override
  double? estimateMaxScrollOffset(int firstIndex, int lastIndex, double leadingScrollOffset, double trailingScrollOffset) {
    scrollCallback(firstIndex, lastIndex);
    return super.estimateMaxScrollOffset(firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }
}
