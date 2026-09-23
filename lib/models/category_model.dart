import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    this.id,
    required this.name,
    this.icon,
    this.isDefault = false,
    required this.createdAt,
  });
  final int? id;
  final String name;
  final String? icon;
  final bool isDefault;
  final DateTime createdAt;

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: map[DbConstants.colId] as int?,
    name: map[DbConstants.colName] as String,
    icon: map[DbConstants.colIcon] as String?,
    isDefault: (map[DbConstants.colIsDefault] as int? ?? 0) == 1,
    createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colName: name,
    DbConstants.colIcon: icon,
    DbConstants.colIsDefault: isDefault ? 1 : 0,
    DbConstants.colCreatedAt: createdAt.toIso8601String(),
  };

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    bool? isDefault,
    DateTime? createdAt,
  }) => CategoryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [id, name, icon, isDefault, createdAt];
}
