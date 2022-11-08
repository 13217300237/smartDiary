import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

/// 时间日期选择器的特别格式
//a base class for picker data model
class CommonPickerModel extends BasePickerModel {
  late List<String> leftList;
  late List<String> middleList;
  late List<String> rightList;
  late DateTime currentTime;
  late int _currentLeftIndex;
  late int _currentMiddleIndex;
  late int _currentRightIndex;

  late LocaleType locale;

  CommonPickerModel({LocaleType? locale}) : locale = locale ?? LocaleType.en;

  @override
  String? leftStringAtIndex(int index) {
    return null;
  }

  @override
  String? middleStringAtIndex(int index) {
    return null;
  }

  @override
  String? rightStringAtIndex(int index) {
    return null;
  }

  @override
  int currentLeftIndex() {
    return _currentLeftIndex;
  }

  @override
  int currentMiddleIndex() {
    return _currentMiddleIndex;
  }

  @override
  int currentRightIndex() {
    return _currentRightIndex;
  }

  @override
  void setLeftIndex(int index) {
    _currentLeftIndex = index;
  }

  @override
  void setMiddleIndex(int index) {
    _currentMiddleIndex = index;
  }

  @override
  void setRightIndex(int index) {
    _currentRightIndex = index;
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 0];
  }

  @override
  DateTime? finalTime() {
    return null;
  }
}

/// 仅选择年月的时间日期选择器模式
//a date picker model
class CustomPicker extends CommonPickerModel {
  late DateTime maxTime;
  late DateTime minTime;

  CustomPicker({DateTime? currentTime, DateTime? maxTime, DateTime? minTime, LocaleType? locale}) : super(locale: locale) {
    this.maxTime = maxTime ?? DateTime(2249, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();

    if (currentTime.compareTo(this.maxTime) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime) < 0) {
      currentTime = this.minTime;
    }

    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentLeftIndex = this.currentTime.year - this.minTime.year;
    _currentMiddleIndex = this.currentTime.month - minMonth;
    _currentRightIndex = this.currentTime.day - minDay;
  }

  void _fillLeftLists() {
    leftList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  final List<int> _leapYearMonths = const <int>[1, 3, 5, 7, 8, 10, 12];

  int calcDateCount(int year, int month) {
    if (_leapYearMonths.contains(month)) {
      return 31;
    } else if (month == 2) {
      if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return 29;
      }
      return 28;
    }
    return 30;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year && currentTime.month == maxTime.month ? maxTime.day : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year && currentTime.month == minTime.month ? minTime.day : 1;
  }

  void _fillMiddleLists() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();

    middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return _localeMonth(minMonth + index);
    });
  }

  void _fillRightLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    rightList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    //adjust middle
    int destYear = index + minTime.year;
    int minMonth = _minMonthOfCurrentYear();
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
        destYear,
        currentTime.month,
        calcDateCount(destYear, 2),
      )
          : DateTime(
        destYear,
        currentTime.month,
        calcDateCount(destYear, 2),
      );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
        destYear,
        currentTime.month,
        currentTime.day,
      )
          : DateTime(
        destYear,
        currentTime.month,
        currentTime.day,
      );
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillRightLists();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentMiddleIndex = currentTime.month - minMonth;
    _currentRightIndex = currentTime.day - minDay;
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    //adjust right
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    )
        : DateTime(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillRightLists();
    int minDay = _minDayOfCurrentMonth();
    _currentRightIndex = currentTime.day - minDay;
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
      currentTime.year,
      currentTime.month,
      minDay + index,
    )
        : DateTime(
      currentTime.year,
      currentTime.month,
      minDay + index,
    );
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      List monthStrings = i18nObjInLocale(locale)['monthLong'] as List<String>;
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }
}
