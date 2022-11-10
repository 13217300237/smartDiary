import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import '../../../comm/asset_manager.dart';
import '../../../comm/time.dart';
import '../../base/loading_view.dart';
import '../vm/event_search_vm.dart';
import '../widget/filter_widget.dart';
import 'event_search_controller.dart';

class EventSearchPage2 extends StatelessWidget {
  EventSearchPage2({Key? key}) : super(key: key);

  final EventSearchController c = Get.put(EventSearchController());

  final FocusNode text1FocusNode = FocusNode();
  final DateFormatFunc dateFormatFunc = getDateStrV4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('事件搜索', style: TextStyle(color: Colors.white)), backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7)),
      // GetBuilder 使用它之后，项目中可以从此不再使用StatefulWidget，因为StatefulWidget中的所有方法都可以在GetBuilder中找到
      body: GetBuilder<EventSearchController>(builder: (c) {
        return Center(child: Column(children: [_searchLayout(context), _filterLayout(context)]));
      }, initState: (_) {
        c.initData();
      }, dispose: (_) {
        c.initData();
      }),
    );
  }

  _searchLayout(context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(0)),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(children: [Expanded(child: _searchTextField(context))]),
            Positioned(
              right: 15,
              child: GestureDetector(
                  onTap: () {
                    if (c.searchTextController.text.isNotEmpty) {
                      _onSubmitSearch();
                    } else {
                      showToast('请输入搜索关键字');
                      text1FocusNode.requestFocus();
                    }
                  },
                  child: Image.asset(AssetManager.png('search'), color: Colors.white, width: 20)),
            ),
            // if (_vm.searchText.isNotEmpty)
            Positioned(
              right: 45,
              child: GestureDetector(
                  onTap: () {
                    c.searchTextController.text = '';
                    _onSubmitSearch();
                  },
                  child: Image.asset(AssetManager.png('delete'), color: Colors.white, width: 30)),
            ),
          ],
        ));
  }

  _searchTextField(context) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).buttonColor),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        margin: const EdgeInsets.only(left: 0, right: 0),
        child: TextField(
            focusNode: text1FocusNode,
            readOnly: false,
            onSubmitted: (v) => _onSubmitSearch(),
            controller: c.searchTextController,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            cursorColor: Colors.orange,
            maxLines: 1,
            showCursor: true,
            decoration: InputDecoration(
                hintText: '请输入搜索关键字',
                hintStyle: const TextStyle(
                  color: Colors.white,
                ),
                border: InputBorder.none,
                labelStyle: TextStyle(color: Theme.of(context).buttonColor))));
  }

  _onSubmitSearch() {
    text1FocusNode.unfocus();
    c.queryData(dateFormatFunc: dateFormatFunc);
  }

  _filterLayout(context) {
    return Expanded(
        child: Obx(() => LoadingView(
              loadingStatus: c.loadingStatue.value,
              child: DefaultTabController(
                  length: c.groupData.length,
                  child: Container(
                      color: Theme.of(context).primaryColor,
                      child: Column(children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(AssetManager.png('tag'), width: 40, color: Theme.of(context).buttonColor.withOpacity(.7)),
                            ),
                            Expanded(
                              child: ButtonsTabBar(
                                  backgroundColor: Theme.of(context).buttonColor,
                                  unselectedBackgroundColor: Colors.blueGrey[200],
                                  borderColor: Colors.transparent,
                                  unselectedBorderColor: Colors.transparent,
                                  splashColor: Theme.of(context).primaryColor,
                                  borderWidth: 2,
                                  labelSpacing: 2,
                                  contentPadding: const EdgeInsets.only(left: 7, right: 7),
                                  height: 40,
                                  tabs: c.groupData.keys.map((e) {
                                    String tag = e.isEmpty ? '无标签' : e;
                                    return Tab(
                                        child: Text(tag, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.displayLarge!.color)));
                                  }).toList()),
                            ),
                          ],
                        ),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                child: TabBarView(
                                    // 这里的 dateFilterMap 指的是 Map<String, List<EventEntity>>
                                    children: c.groupData.values.map((dateFilterMap) {
                                  debugPrint('${dateFilterMap.keys}');
                                  return FilterWidget(
                                    dateFilterMap: dateFilterMap,
                                    callback: () {
                                      c.queryData(dateFormatFunc: dateFormatFunc);
                                    },
                                  );
                                }).toList())))
                      ]))),
            )));
  }
}
