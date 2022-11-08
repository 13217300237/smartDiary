import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_diary/comm/tag_cache.dart';

void showDeleteDialog(BuildContext context, int id, Function(int id)? onDeleteCallback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示', style: TextStyle(fontSize: 20, color: Theme.of(context).textSelectionColor.withRed(100).withBlue(200))),
          titlePadding: const EdgeInsets.all(15),
          titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            "您确定要删除吗?",
            style: TextStyle(fontSize: 16, color: Theme.of(context).textSelectionColor),
          ),
          contentPadding: const EdgeInsets.all(15),
          contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
          actions: [
            TextButton(
              child: Text("再考虑一下", style: TextStyle(fontSize: 18, color: Theme.of(context).textSelectionColor)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              onPressed: () {
                onDeleteCallback?.call(id);
                Navigator.of(context).pop(false);
              },
              child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor.withRed(100).withGreen(100))),
            )
          ],
        );
      });
}

void showDeleteDialogV2(BuildContext context, String text, Function(String text)? onDeleteCallback) {
  var span1 = TextSpan(text: '您确定要删除标签', style: TextStyle(color: Theme.of(context).textSelectionColor, fontSize: 16));
  var span2 = TextSpan(text: text, style: TextStyle(color: Theme.of(context).buttonColor.withGreen(29), fontSize: 18));
  var span3 = TextSpan(text: '吗?', style: TextStyle(color: Theme.of(context).textSelectionColor, fontSize: 16));

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('提示', style: TextStyle(fontSize: 20, color: Theme.of(context).textSelectionColor)),
          titlePadding: const EdgeInsets.all(15),
          backgroundColor: Theme.of(context).primaryColor,
          titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
          content: Text.rich(TextSpan(children: [span1, span2, span3])),
          contentPadding: const EdgeInsets.all(15),
          contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
          actions: [
            TextButton(
              child: Text("再考虑一下", style: TextStyle(fontSize: 18, color: Theme.of(context).textSelectionColor)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              onPressed: () {
                onDeleteCallback?.call(text);
                Navigator.of(context).pop(false);
              },
              child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).textSelectionColor.withRed(100).withGreen(100))),
            )
          ],
        );
      });
}

List<String> tags = [];
TextEditingController tagController = TextEditingController();

Future<String?> showTagChooseDialog(BuildContext context, String oriTag) async {
  tags = [];
  tagController.text = oriTag;

  void _initTag(StateSetter setState) {
    TagCachePool().getTagList.then((tagList) {
      setState(() {
        tags = tagList;
      });
    });
  }

  Widget _tagItem(String text, StateSetter setState) {
    return GestureDetector(
      onTap: () {
        tagController.text = text;
      },
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.only(left: 10, top: 8, right: 10, bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).buttonColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(width: 10),
            GestureDetector(
                onTap: () {
                  showDeleteDialogV2(context, text, (str) {
                    TagCachePool().remove(text).then((value) {
                      _initTag(setState);
                    });
                  });
                },
                child: const Icon(Icons.close, color: Colors.white, size: 20)),
          ],
        ),
      ),
    );
  }

  return showDialog<String>(
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          _initTag(setState);
          return AlertDialog(
            title: const Text('事件标签', style: TextStyle(fontSize: 20)),
            titlePadding: const EdgeInsets.all(15),
            titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 25),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    TextField(
                      controller: tagController,
                      maxLength: 10,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                      cursorColor: Theme.of(context).buttonColor,
                      decoration: const InputDecoration(
                          hintText: '输入新标签', hintStyle: TextStyle(fontSize: 16), border: InputBorder.none, labelText: '选择或输入标签'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 200,
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(), child: Wrap(children: tags.map((e) => _tagItem(e, setState)).toList())),
                ),
                const SizedBox(height: 10),
              ],
            ),
            contentPadding: const EdgeInsets.all(15),
            contentTextStyle: const TextStyle(color: Colors.black54, fontSize: 19),
            actions: [
              TextButton(
                child: const Text("取消", style: TextStyle(fontSize: 18, color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(tagController.text);
                },
                child: Text('确定', style: TextStyle(fontSize: 18, color: Theme.of(context).buttonColor)),
              )
            ],
          );
        });
      },
      context: context);
}
