import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image/image.dart';
import 'package:oktoast/oktoast.dart';
import 'package:smart_diary/page/base/loading_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../../comm/const.dart';
import '../../../comm/time.dart';
import '../../../db/entity/event.dart';
import '../../../db/event_db_provider.dart';

typedef DateFormatFunc = String Function(int dateInt);

class EventSearchVm extends ChangeNotifier {
  List<EventEntity> searchResList = []; // 未分组的原始数据

  late DateFormatFunc dateFormatFunc; // 定义日期的过滤形式

  // 最外层，用TAG去过滤，value中存两个东西，第一，当前时间数组，第二，当前下的对象数组
  Map<String, Map<String, List<EventEntity>>> groupData = {};

  /// 把事件日期 按照日期以及 标签 进行二级过滤
  /// 再加上关键字的内容搜索，相当于三级过滤了
  ///
  /// OK就这样决定。
  TextEditingController searchTextController = TextEditingController();

  String get searchText => searchTextController.text;

  final EventDbProvider _provider = EventDbProvider();

  LoadingStatus loadingStatue = LoadingStatus.loadingSucButEmpty;

  queryData({required DateFormatFunc dateFormatFunc}) async {
    searchResList.clear();
    groupData.clear();
    loadingStatue = LoadingStatus.loading;
    notifyListeners();

    this.dateFormatFunc = dateFormatFunc;

    bool res = await _queryByCondition(searchTextController.text);
    if (res != true) {
      loadingStatue = LoadingStatus.loadingSucButEmpty;
      notifyListeners();
      return;
    }

    // 先按照tag分组
    for (var tag in getTags(searchResList)) {
      List<EventEntity> tagFilterList;
      if (tag == strAll) {
        tagFilterList = searchResList;
      } else {
        // 得到当前tag下的所有对象list
        tagFilterList = searchResList.where((e2) => e2.tag == tag).toList();
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
      loadingStatue = LoadingStatus.loadingSucButEmpty;
    } else {
      loadingStatue = LoadingStatus.loadingSuc;
    }

    EasyLoading.dismiss();
    notifyListeners();
  }

  Future<bool> _queryByCondition(String condition) async {
    debugPrint('执行查询$condition');

    // 查询条件是空，则不要执行
    if (condition.isEmpty) {
      loadingStatue = LoadingStatus.loadingSucButEmpty;
      notifyListeners();
      return false;
    }
    List<EventEntity> list = await _provider.queryAllCompile(condition: condition);

    searchResList.clear();
    searchResList.addAll(list);

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

  void refresh() {
    notifyListeners();
  }
}
