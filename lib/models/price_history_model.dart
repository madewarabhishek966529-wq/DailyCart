import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class PriceHistoryModel extends Equatable {
  const PriceHistoryModel({
    this.id,
    required this.itemName,
    this.categoryId,
    this.unit,
    required this.price,
    required this.recordedAt,
  });
  final int? id;
  final String itemName;
  final int? categoryId;
  final String? unit;
  final double price;
  final DateTime recordedAt;

  factory PriceHistoryModel.fromMap(Map<String, dynamic> map) =>
      PriceHistoryModel(
        id: map[DbConstants.colId] as int?,
        itemName: map[DbConstants.colItemName] as String,
        categoryId: map[DbConstants.colCategoryId] as int?,
        unit: map[DbConstants.colUnit] as String?,
        price: (map[DbConstants.colPrice] as num).toDouble(),
        recordedAt: DateTime.parse(map[DbConstants.colRecordedAt] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colItemName: itemName,
    DbConstants.colCategoryId: categoryId,
    DbConstants.colUnit: unit,
    DbConstants.colPrice: price,
    DbConstants.colRecordedAt: recordedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    itemName,
    categoryId,
    unit,
    price,
    recordedAt,
  ];
}
