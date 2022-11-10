import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:smart_diary/page/event/vm/event_search_vm.dart';

import '../../../comm/const.dart';
import '../../../db/entity/event.dart';
import '../../../db/event_db_provider.dart';
import '../../base/loading_view.dart';

class EventSearchController extends GetxController {
  TextEditingController searchTextController = TextEditingController();

  final EventDbProvider _provider = EventDbProvider();

  late DateFormatFunc dateFormatFunc; // 定义日期的过滤形式
  final List<EventEntity> _searchResList = []; // 未分组的原始数据, 无需监听它

  // 只有需要暴露出去的对象才加上Obs
  var loadingStatue = LoadingStatus.loadingSucButEmpty.obs;
  final groupData = <String, Map<String, List<EventEntity>>>{}.obs; // 这才是需要监听的，对外暴露的对象

  queryData({required DateFormatFunc dateFormatFunc}) async {
    _searchResList.clear();
    groupData.clear();
    this.dateFormatFunc = dateFormatFunc;

    bool res = await _queryByCondition(searchTextController.text);
    if (res != true) {
      loadingStatue.value = LoadingStatus.loadingSucButEmpty;
      return;
    }

    // 先按照tag分组
    for (var tag in getTags(_searchResList)) {
      List<EventEntity> tagFilterList;
      if (tag == strAll) {
        tagFilterList = _searchResList;
      } else {
        // 得到当前tag下的所有对象list
        tagFilterList = _searchResList.where((e2) => e2.tag == tag).toList();
      }
      // 再按照日期去区分
      Map<String, List<EventEntity>> dateFilterRes = {};
      for (var date in getDates(tagFilterList)) {
        if (date != strAll) {
          dateFilterRes.putIfAbsent(date, () => tagFilterList.where((element) => dateFormatFunc(element.date!) == date).toList());
        } else {
          dateFilterRes.putIfAbsent(date, () => tagFilterList.toList());
        }
      }

      groupData.putIfAbsent(tag, () => dateFilterRes);
    }

    if (groupData.isEmpty) {
      loadingStatue.value = LoadingStatus.loadingSucButEmpty;
    } else {
      loadingStatue.value = LoadingStatus.loadingSuc;
    }
  }

  Future<bool> _queryByCondition(String condition) async {
    debugPrint('执行查询$condition');

    // 查询条件是空，则不要执行
    if (condition.isEmpty) {
      loadingStatue.value = LoadingStatus.loadingSucButEmpty;
      return false;
    }
    List<EventEntity> list = await _provider.queryAllCompile(condition: condition);

    _searchResList.clear();
    _searchResList.addAll(list);

    return list.isNotEmpty;
  }

  // 区分出搜索结果列表中的所有标签
  Set<String> getTags(List<EventEntity> searchResList) {
    Set<String> set = {};
    set.add(strAll);
    var temp = searchResList.map((e) {
      if (e.tag == null || e.tag!.isEmpty) {
        return '';
      }

      return e.tag!;
    }).toSet();

    set.addAll(temp);
    return set;
  }

  // 区分出搜索结果列表中的所有标签
  Set<String> getDates(List<EventEntity> searchResList) {
    Set<String> finalSet = {};
    finalSet.add(strAll);
    Set<String> temp = searchResList.where((element) => element.date != null && element.date != 0).map((e) {
      return dateFormatFunc(e.date!);
    }).toSet();
    finalSet.addAll(temp);

    return finalSet;
  }

  void initData() {
    loadingStatue.value = LoadingStatus.loadingSucButEmpty;
    searchTextController.clear();
    groupData.clear();
  }
}
