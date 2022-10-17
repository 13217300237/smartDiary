import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AssetEntityCachePool {
  AssetEntityCachePool._internal() {
    init();
  }

  // static final修饰了_singleton，_singleton会在编译期被初始化，保证了特征3
  static final AssetEntityCachePool _singleton = AssetEntityCachePool._internal();

  final Map<String, AssetEntity> _map = {};

  void init() {
    _map.clear();
  }

  factory AssetEntityCachePool() => _singleton;

  AssetEntity? get(String assetId) {
    return _map[assetId];
  }

  void put(String assetId, AssetEntity e) {
    _map[assetId] = e;
  }
}
