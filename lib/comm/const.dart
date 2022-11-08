import 'package:flutter/material.dart';

import 'package:event_bus/event_bus.dart';

const String firstTimeRunningTag = 'firstTimeRunning';

const int minutesCountToShowJustNow = 5; // 如果事件的创建事件与当前时间差距是5分钟以内，就不显示具体时间，而是显示 刚才

int assetMaxCount = 4; // 列表中事件卡片图片显示的最大张数

String strAll = '全部';

const availableColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.amber,
  Colors.orange,
];

EventBus eventBus = EventBus();


const String defaultFontFamily = '';
const String alimamaFontFamily = 'alimama';
const String TsangerYuYangTFontFamily = 'TsangerYuYangT';
const String zcool = 'zcool';
