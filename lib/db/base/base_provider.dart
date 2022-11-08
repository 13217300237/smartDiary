import '../comm.dart';
import '../db_core.dart';
import 'base_entity.dart';

abstract class BaseDbProvider<T extends BaseEntity> {
  /// 主表名，每一个provider有一个主表名
  String get tableName;

  /// 实例对象，由于dart不支持反射，所以执行fromMap函数需要一个实例化的对象
  T get t;

  /// 当前表中所有的列名
  List<String> get columns;

  /// 唯一主键的列名
  String get columnPrimaryId;

  /// 插入单条数据
  Future<int> insertOne(T t) async {
    return await DbCore.db.insert(tableName, t.toJson());
  }

  /// 获得单条数据, 创建对象时，只需要指定id即可
  Future<T?> getEntityById(int id) async {
    List<Map>? maps = await DbCore.db.query(
      tableName,
      columns: columns,
      where: '$columnPrimaryId = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return t.fromJson(maps.first as Map<String, dynamic>) as T;
  }

  /// 查询所有数据，基类中未提供详细的按条件查询的语句，各子类可以自行继承方法之后进行自定义
  Future<List<T>> queryAll({String? orderColumn}) async {
    List<T> listEntity = [];
    List<Map<String, dynamic>> list = await DbCore.db.query(tableName, orderBy: orderColumn);
    for (var e in list) {
      listEntity.add(t.fromJson(e) as T);
    }
    return listEntity;
  }

  /// 删除单条数据
  Future<int> delete(int id) async {
    return DbCore.db.delete(tableName, where: '$columnPrimaryId = ?', whereArgs: [id]);
  }

  /// 更新单条数据
  Future<int> update(T t) {
    return DbCore.db.update(tableName, t.toJson(), where: '$columnPrimaryId = ?', whereArgs: [t.id]);
  }
}
