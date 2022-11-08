import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_diary/comm/dialog.dart';

import '../../../comm/asset_manager.dart';
import '../../../comm/time.dart';
import '../../../db/entity/event.dart';
import '../page/event_detail_page.dart';
import '../vm/event_input_vm.dart';

Widget eventCard({required EventEntity entity, required BuildContext context, double? maxWidth, Function? onTab, Function(int id)? onDelete}) {
  return GestureDetector(
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) {
          return EventDetailPage(entity: entity, pageState: PageState.readOnly);
        })).then((value) {
          onTab?.call();
        });
      },
      onLongPress: () {
        if (onDelete != null) {
          showDeleteDialog(context, entity.id!, onDelete);
        }
      },
      child: Card(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          color: Theme.of(context).buttonColor.withOpacity(.11),
          shadowColor: Colors.black.withOpacity(1),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
            child: Stack(children: [
              SizedBox(
                  width: maxWidth,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(entity.title ?? '',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).textSelectionColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 10),
                    Text(
                      entity.content ?? '',
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Theme.of(context).textSelectionColor),
                    ),
                    const SizedBox(height: 20),
                    imgAssetWrap(entity, context),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      getTimeWidget(entity, context),
                      const SizedBox(width: 20),
                      if (entity.tag == null || entity.tag!.isEmpty)
                        const SizedBox(height: 20)
                      else
                        Container(
                            constraints: const BoxConstraints(maxWidth: 100),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor.withOpacity(.6)),
                            child: Text('${entity.tag}', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)))
                    ])
                  ]))
            ]),
          )));
}
