import 'package:flutter/material.dart';

import '../../../db/entity/event.dart';
import 'event_card.dart';

class FilterWidget extends StatefulWidget {
  Function callback;
  Map<String, List<EventEntity>> dateFilterMap;

  FilterWidget({Key? key, required this.dateFilterMap, required this.callback}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FilterWidgetState();
  }
}

class FilterWidgetState extends State<FilterWidget> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ListView.builder(
                itemBuilder: (context, index) {
                  String date = widget.dateFilterMap.keys.toList()[index];
                  int count = widget.dateFilterMap.values.toList()[index].length;

                  return GestureDetector(
                      onTap: () {
                        if (currentIndex != index) {
                          currentIndex = index;
                          setState(() {});
                        }
                      },
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: currentIndex == index ? Theme.of(context).buttonColor : Colors.grey[400],
                          ),
                          height: 100,
                          child: Center(
                              child: Text(
                            '$date\n($count)',
                            style: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),
                            textAlign: TextAlign.center,
                          ))));
                },
                itemCount: widget.dateFilterMap.length),
          )),
      const SizedBox(width: 10),
      Expanded(
          flex: 10,
          child: ListView.builder(
              itemBuilder: (context, index) {
                return eventCard(
                  entity: widget.dateFilterMap.values.toList()[currentIndex][index],
                  context: context,
                  maxWidth: null,
                  onTab: widget.callback,
                );
              },
              itemCount: widget.dateFilterMap.values.toList()[currentIndex].length,
              physics: const BouncingScrollPhysics()))
    ]);
  }
}
