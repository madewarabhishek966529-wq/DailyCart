import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class FrequentItemModel extends Equatable {
  const FrequentItemModel({
    this.id,
    required this.name,
    this.categoryId,
    this.defaultQuantity = 1,
    this.defaultUnit = 'piece',
    this.defaultPrice = 0,
    this.usageCount = 0,
    this.lastUsedAt,
  });
  final int? id;
  final String name;
  final int? categoryId;
  final double defaultQuantity;
  final String defaultUnit;
  final double defaultPrice;
  final int usageCount;
  final DateTime? lastUsedAt;

  factory FrequentItemModel.fromMap(Map<String, dynamic> map) =>
      FrequentItemModel(
        id: map[DbConstants.colId] as int?,
        name: map[DbConstants.colName] as String,
        categoryId: map[DbConstants.colCategoryId] as int?,
        defaultQuantity: (map[DbConstants.colDefaultQuantity] as num? ?? 1)
            .toDouble(),
        defaultUnit: map[DbConstants.colDefaultUnit] as String? ?? 'piece',
        defaultPrice: (map[DbConstants.colDefaultPrice] as num? ?? 0)
            .toDouble(),
        usageCount: map[DbConstants.colUsageCount] as int? ?? 0,
        lastUsedAt: map[DbConstants.colLastUsedAt] != null
            ? DateTime.parse(map[DbConstants.colLastUsedAt] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colName: name,
    DbConstants.colCategoryId: categoryId,
    DbConstants.colDefaultQuantity: defaultQuantity,
    DbConstants.colDefaultUnit: defaultUnit,
    DbConstants.colDefaultPrice: defaultPrice,
    DbConstants.colUsageCount: usageCount,
    DbConstants.colLastUsedAt: lastUsedAt?.toIso8601String(),
  };

  FrequentItemModel copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? defaultQuantity,
    String? defaultUnit,
    double? defaultPrice,
    int? usageCount,
    DateTime? lastUsedAt,
  }) => FrequentItemModel(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    defaultQuantity: defaultQuantity ?? this.defaultQuantity,
    defaultUnit: defaultUnit ?? this.defaultUnit,
    defaultPrice: defaultPrice ?? this.defaultPrice,
    usageCount: usageCount ?? this.usageCount,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    categoryId,
    defaultQuantity,
    defaultUnit,
    defaultPrice,
    usageCount,
    lastUsedAt,
  ];
}
