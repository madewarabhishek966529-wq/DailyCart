import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class TemplateModel extends Equatable {
  const TemplateModel({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int itemCount;

  factory TemplateModel.fromMap(Map<String, dynamic> map) => TemplateModel(
    id: map[DbConstants.colId] as int?,
    name: map[DbConstants.colName] as String,
    createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
    updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
    itemCount: map['item_count'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colName: name,
    DbConstants.colCreatedAt: createdAt.toIso8601String(),
    DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
  };

  TemplateModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
  }) => TemplateModel(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    itemCount: itemCount ?? this.itemCount,
  );

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, itemCount];
}
