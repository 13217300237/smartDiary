// 代办超时未完成数量

class UndoneExpiredTodoEntity {
  int count;

  String get countStr {
    if (count < 99) {
      return '$count';
    } else {
      return '99+';
    }
  }

  UndoneExpiredTodoEntity(this.count);
}
