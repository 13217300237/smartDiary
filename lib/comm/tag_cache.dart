import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagCachePool {
  TagCachePool._internal() {
    _initInstance();
  }

  SharedPreferences? _sp;

  // static final修饰了_singleton，_singleton会在编译期被初始化，保证了单例
  static final TagCachePool _singleton = TagCachePool._internal();

  final Set<String> _list = <String>{};

  void _initInstance() {}

  factory TagCachePool() => _singleton;

  final String _key = 'TagCache';

  initCache() async {
    _sp ??= await SharedPreferences.getInstance();
    List<String>? cache = _sp!.getStringList(_key);
    _list.clear();
    cache?.forEach((element) {
      _list.add(element);
    });
  }

  Future<bool> clear() async {
    return _sp!.clear();
  }

  Future<bool> saveTag(String text) async {
    if (text.isEmpty) {
      return Future.value(false);
    }

    _list.add(text);
    Future<bool> r = _sp!.setStringList(_key, _list.toList());
    return r;
  }

  Future<List<String>> get getTagList async {
    await initCache();
    return _list.toList().reversed.toList();
  }

  Future<bool> remove(String text) async {
    _list.remove(text);
    Future<bool> r = _sp!.setStringList(_key, _list.toList());
    return r;
  }
}
