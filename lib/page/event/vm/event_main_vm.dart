import 'package:flutter/cupertino.dart';
import 'package:smart_diary/db/entity/event.dart';
import 'package:smart_diary/page/base/loading_view.dart';

import '../../../db/event_db_provider.dart';

class EventMainVm extends ChangeNotifier {
  final EventDbProvider _provider = EventDbProvider();
  String? yearMonth; // 年月

  LoadingStatus loadingStatus = LoadingStatus.loading;

  List<EventEntity> get listEventEntity => _listEventEntity;
  final List<EventEntity> _listEventEntity = [];

  void requestData() async {
    loadingStatus = LoadingStatus.loading;
    notifyListeners();

    _listEventEntity.clear();
    _listEventEntity.addAll(await _provider.queryAllCompile(yearMonth: yearMonth));

    // 检测数据，如果有
    if (_listEventEntity.isNotEmpty) {
      loadingStatus = LoadingStatus.loadingSuc;
    } else {
      loadingStatus = LoadingStatus.loadingSucButEmpty;
    }

    notifyListeners();
  }

  Future<bool> deleteById(int id) async {
    return await _provider.delete(id) > 0;
  }
}
