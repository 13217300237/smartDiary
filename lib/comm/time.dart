import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../db/entity/event.dart';
import 'const.dart';

/// 完整的格式，年月日时分
List<String> dateFormatYMDHN = ['yyyy', '年', 'mm', '月', 'dd', '日', 'HH', ':', 'nn'];

/// 年月
List<String> dateFormatYM = ['yyyy', '年', 'mm', '月'];

/// 时分
List<String> dateFormatHN = ['HH', ':', 'nn'];

/// 年月日
List<String> dateFormatYMD = ['yyyy', '年', 'mm', '月','dd','日'];

/// 简体中文格式
DateLocale dateLocale = const SimplifiedChineseDateLocale();


String getDateStr(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time), dateFormatYMD, locale: const SimplifiedChineseDateLocale());
}

String getDateStrV2(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time), dateFormatHN, locale: const SimplifiedChineseDateLocale());
}

String getDateStrV3(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time), dateFormatYMDHN, locale: const SimplifiedChineseDateLocale());
}

String getDateStrV4(int time) {
  return formatDate(DateTime.fromMillisecondsSinceEpoch(time), dateFormatYM, locale: const SimplifiedChineseDateLocale());
}


String getWeekDay(int dateInt) {
  int weekDay = DateTime.fromMillisecondsSinceEpoch(dateInt).weekday;
  switch (weekDay) {
    case 1:
      return '星期一';
    case 2:
      return '星期二';
    case 3:
      return '星期三';
    case 4:
      return '星期四';
    case 5:
      return '星期五';
    case 6:
      return '星期六';
    case 7:
      return '星期日';
  }

  return 'unknown';
}

// 如果当前事件的时间与当前事件差小于5分钟，就显示刚才
Widget getTimeWidget(EventEntity entity,BuildContext context) {
  var textStyle = TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 12);
  var textStyle2 = TextStyle(color: Theme.of(context).textTheme.displayLarge!.color, fontSize: 12);

  var eventDateInt = entity.date;
  if (eventDateInt == null) return Text(getDateStrV2(entity.date ?? 0), style: textStyle);
  DateTime eventDateTime = DateTime.fromMillisecondsSinceEpoch(eventDateInt);
  DateTime nowDateTime = DateTime.now();

  int m = nowDateTime.difference(eventDateTime).inMinutes;

  if (m > minutesCountToShowJustNow) {
    return Text(getDateStrV2(entity.date ?? 0), style: textStyle);
  } else {
    return Text('刚才', style: textStyle2);
  }
}
