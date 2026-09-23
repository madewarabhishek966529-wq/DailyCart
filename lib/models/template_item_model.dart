import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class TemplateItemModel extends Equatable {
  const TemplateItemModel({
    this.id,
    required this.templateId,
    required this.name,
    this.categoryId,
    this.quantity = 1,
    this.unit = 'piece',
    this.defaultPrice = 0,
  });
  final int? id;
  final int templateId;
  final String name;
  final int? categoryId;
  final double quantity;
  final String unit;
  final double defaultPrice;

  factory TemplateItemModel.fromMap(Map<String, dynamic> map) =>
      TemplateItemModel(
        id: map[DbConstants.colId] as int?,
        templateId: map[DbConstants.colTemplateId] as int,
        name: map[DbConstants.colName] as String,
        categoryId: map[DbConstants.colCategoryId] as int?,
        quantity: (map[DbConstants.colQuantity] as num? ?? 1).toDouble(),
        unit: map[DbConstants.colUnit] as String? ?? 'piece',
        defaultPrice: (map[DbConstants.colDefaultPrice] as num? ?? 0)
            .toDouble(),
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colTemplateId: templateId,
    DbConstants.colName: name,
    DbConstants.colCategoryId: categoryId,
    DbConstants.colQuantity: quantity,
    DbConstants.colUnit: unit,
    DbConstants.colDefaultPrice: defaultPrice,
  };

  TemplateItemModel copyWith({
    int? id,
    int? templateId,
    String? name,
    int? categoryId,
    double? quantity,
    String? unit,
    double? defaultPrice,
  }) => TemplateItemModel(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    defaultPrice: defaultPrice ?? this.defaultPrice,
  );

  @override
  List<Object?> get props => [
    id,
    templateId,
    name,
    categoryId,
    quantity,
    unit,
    defaultPrice,
  ];
}
