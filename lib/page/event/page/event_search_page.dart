import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:smart_diary/comm/asset_manager.dart';
import 'package:smart_diary/page/base/loading_view.dart';

import '../../../comm/time.dart';
import '../vm/event_search_vm.dart';
import '../widget/filter_widget.dart';

class EventSearchPage extends StatefulWidget {
  const EventSearchPage({Key? key}) : super(key: key);

  @override
  _EventSearchPageState createState() => _EventSearchPageState();
}

class _EventSearchPageState extends State<EventSearchPage> {
  final EventSearchVm _vm = EventSearchVm();
  FocusNode text1FocusNode = FocusNode();
   DateFormatFunc dateFormatFunc = getDateStrV4;

  @override
  void initState() {
    super.initState();
    _vm.queryData(dateFormatFunc: dateFormatFunc);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => _vm,
        builder: (context, child) {
          return Consumer<EventSearchVm>(builder: (context, vm, child) {
            return Scaffold(
                appBar: AppBar(
                    title: const Text('事件搜索', style: TextStyle(color: Colors.white)),
                    backgroundColor: Theme.of(context).buttonColor.withOpacity(0.7)),
                body: Column(children: [
                  _searchLayout(),
                  _filterLayout(),
                ]));
          });
        });
  }

  _searchTextField() {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Theme.of(context).buttonColor),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        margin: const EdgeInsets.only(left: 0, right: 0),
        child: TextField(
            focusNode: text1FocusNode,
            onChanged: (t) {
              _vm.refresh();
            },
            readOnly: false,
            onSubmitted: (v) => _onSubmitSearch(v),
            controller: _vm.searchTextController,
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

  _onSubmitSearch(String v) {
    text1FocusNode.unfocus();
    _vm.queryData(dateFormatFunc: dateFormatFunc);
  }

  _searchLayout() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(0)),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(children: [
              Expanded(child: _searchTextField()),
            ]),
            Positioned(
              right: 15,
              child: GestureDetector(
                  onTap: () {
                    if (_vm.searchTextController.text.isNotEmpty) {
                      _onSubmitSearch(_vm.searchTextController.text);
                    } else {
                      showToast('请输入搜索关键字');
                      text1FocusNode.requestFocus();
                    }
                  },
                  child: Image.asset(AssetManager.png('search'), color: Colors.white, width: 20)),
            ),
            if (_vm.searchText.isNotEmpty)
              Positioned(
                right: 45,
                child: GestureDetector(
                    onTap: () {
                      _vm.searchTextController.text = '';
                      _onSubmitSearch(_vm.searchTextController.text);
                    },
                    child: Image.asset(AssetManager.png('delete'), color: Colors.white, width: 30)),
              ),
          ],
        ));
  }

  _filterLayout() {
    return Expanded(
        child: LoadingView(
      loadingStatus: _vm.loadingStatue,
      child: DefaultTabController(
          length: _vm.groupData.length,
          child: Container(
              color: Theme.of(context).primaryColor,
              child: Column(children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(AssetManager.png('tag'),width: 40,color: Theme.of(context).buttonColor.withOpacity(.7),),
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
                          tabs: _vm.groupData.keys.map((e) {
                            String tag = e.isEmpty ? '无标签' : e;
                            return Tab(child: Text(tag, style: TextStyle(fontSize: 16, color: Theme.of(context).textSelectionColor)));
                          }).toList()),
                    ),
                  ],
                ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        child: TabBarView(
                            // 这里的 dateFilterMap 指的是 Map<String, List<EventEntity>>
                            children: _vm.groupData.values.map((dateFilterMap) {
                          debugPrint('${dateFilterMap.keys}');
                          return FilterWidget(
                            dateFilterMap: dateFilterMap,
                            callback: () {
                              _vm.queryData(dateFormatFunc: dateFormatFunc);
                            },
                          );
                        }).toList())))
              ]))),
    ));
  }
}
