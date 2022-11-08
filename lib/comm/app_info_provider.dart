import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_diary/comm/font.dart';

const String fontFamilyKey = 'fontFamily';
const String bgColorKey = 'bgColor';
const String textColorKey = 'textColor';
const String mainColorKey = 'mainColor';
const String dayNightStyleKey = 'dayNightStyle';

/// 黑夜白天模式
enum DayNightStyle { day, night }

class AppInfoProvider extends ChangeNotifier {
  static SharedPreferences? _sp;

  static String? _fontFamily;
  static int? _mainColor;
  static int? _bgColor;
  static int? _textColor;

  static int? _dayNightStyleIndex;

  void init() async {
    await _initSp();
    _fontFamily = _sp!.getString(fontFamilyKey) ?? '';
    _bgColor = _sp!.getInt(bgColorKey) ?? 0xffFFFFFF;
    _textColor = _sp!.getInt(textColorKey) ?? 0xff000000;
    _mainColor = _sp!.getInt(mainColorKey) ?? Colors.green.value;

    debugPrint('_mainColor ===$_mainColor');

    _dayNightStyleIndex = _sp!.getInt(dayNightStyleKey) ?? DayNightStyle.day.index;
    setDayNightStyle(getIfNightStyle ? DayNightStyle.night : DayNightStyle.day);
  }

  String get fontFamily => _fontFamily ?? defaultFontFamily;

  int? get dayNightStyleIndex => _dayNightStyleIndex;

  Color get mainColor => Color(_mainColor ?? Colors.green.value);

  Color get textColor => Color(_textColor ?? 0xffFFFFFF);

  Color get bgColor => Color(_bgColor ?? 0xffFFFFFF);

  Future _initSp() async {
    _sp ??= await SharedPreferences.getInstance();
  }

  bool get getIfNightStyle {
    return _dayNightStyleIndex == DayNightStyle.night.index;
  }

  setMainColor(int color) async {
    _mainColor = color;
    _sp!.setInt(mainColorKey, _mainColor!);
    notifyListeners();
  }

  setFontFamily(String family) async {
    _fontFamily = family;
    _sp!.setString(fontFamilyKey, family);
    notifyListeners();
  }

  setDayNightStyle(DayNightStyle dayNightStyle) {
    _dayNightStyleIndex = dayNightStyle.index;
    _sp!.setInt(dayNightStyleKey, _dayNightStyleIndex!);

    if (_dayNightStyleIndex == DayNightStyle.day.index) {
      // 白天，白底黑字
      _bgColor = Colors.grey[300]!.value;
      _textColor = Colors.black.value;
    } else if (_dayNightStyleIndex == DayNightStyle.night.index) {
      _bgColor = Colors.grey.value;
      _textColor = Colors.white.value;
    } else {
      throw Exception('白天黑夜模式参数错误');
    }

    notifyListeners();
  }
}
