
const String dbName = 'db_smart_daily';
const int dbVersion = 1;

// 事件
const String tableEvent = 'event';
const String columnEventPrimaryId = '_id';
const String columnEventContent = 'content';
const String columnEventTitle = 'title';
const String columnEventDate = 'date';
const String columnEventDay = 'day';
const String columnEventTag = 'tag';
const String columnEventLevel = 'level';
const String columnEventAsset = 'asset'; // 事件允许图片记录

// 资源
const String tableRes = 'res';
const String columnResId = '_id';
const String columnResAssetId = 'assetId';
const String columnResType = 'type';// 资源类型 0图片 1视频 2音频
const String columnResThumb = 'thumb';// 资源缩略图地址
const String columnFilePath = 'filePath'; // 资源地址
const String columnResImageWidth = 'imgWidth';
const String columnResImageHeight = 'imgHeight';
const String columnEventId = 'eventId'; // 外键 事件ID

// 代办
const String tableTodo = 'todo';
const String columnTodoId = '_id';
const String columnTodoTypeName = 'typeName';
const String columnTodoContent = 'content';
const String columnTodoRecordTime = 'recordTime';
const String columnTodoModifyTime = 'modifyTime';
const String columnTodoNoticeTime = 'noticeTime';
const String columnTodoIfDone = 'ifDone';// 0 未完成 1 已完成

// 关于TA
const String tableAboutTheOne = 'aboutTheOne';
const String columnAboutTheOneId = '_id';
const String columnAboutTheOneName = 'theOneName';

// 关于TA的话题
const String tableAboutTheOneTopic = 'aboutTheOneTopic';
const String columnAboutTheOneTopicId = '_id';
const String columnAboutTheOneTopicContent = 'content';
const String columnAboutTheOneTopicColor = 'color';
const String columnTheOneId = 'theOneId'; // 外键 关于TA ID
