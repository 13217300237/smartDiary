abstract class BaseEntity {
  int? id;

  BaseEntity(this.id);

  Map<String, dynamic> toJson();

  BaseEntity fromJson(Map<String, dynamic> map);
}
