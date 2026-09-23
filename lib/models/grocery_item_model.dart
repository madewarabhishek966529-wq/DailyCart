import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

enum ItemPriority { low, normal, high }

extension ItemPriorityX on ItemPriority {
  String get value {
    switch (this) {
      case ItemPriority.low:
        return DbConstants.priorityLow;
      case ItemPriority.normal:
        return DbConstants.priorityNormal;
      case ItemPriority.high:
        return DbConstants.priorityHigh;
    }
  }

  static ItemPriority fromString(String s) {
    switch (s) {
      case DbConstants.priorityLow:
        return ItemPriority.low;
      case DbConstants.priorityHigh:
        return ItemPriority.high;
      default:
        return ItemPriority.normal;
    }
  }
}

class GroceryItemModel extends Equatable {
  const GroceryItemModel({
    this.id,
    required this.listId,
    required this.name,
    this.categoryId,
    this.categoryName,
    this.quantity = 1,
    this.unit = 'piece',
    this.unitPrice = 0,
    this.actualUnitPrice = 0,
    this.totalPrice = 0,
    this.actualTotalPrice = 0,
    this.note,
    this.priority = ItemPriority.normal,
    this.sortOrder = 0,
    this.isPurchased = false,
    required this.createdAt,
    required this.updatedAt,
  });
  final int? id;
  final int listId;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double actualUnitPrice;
  final double totalPrice;
  final double actualTotalPrice;
  final String? note;
  final ItemPriority priority;
  final int sortOrder;
  final bool isPurchased;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GroceryItemModel.fromMap(Map<String, dynamic> map) =>
      GroceryItemModel(
        id: map[DbConstants.colId] as int?,
        listId: map[DbConstants.colListId] as int,
        name: map[DbConstants.colName] as String,
        categoryId: map[DbConstants.colCategoryId] as int?,
        categoryName: map['category_name'] as String?,
        quantity: (map[DbConstants.colQuantity] as num? ?? 1).toDouble(),
        unit: map[DbConstants.colUnit] as String? ?? 'piece',
        unitPrice: (map[DbConstants.colUnitPrice] as num? ?? 0).toDouble(),
        actualUnitPrice: (map[DbConstants.colActualUnitPrice] as num? ?? 0)
            .toDouble(),
        totalPrice: (map[DbConstants.colTotalPrice] as num? ?? 0).toDouble(),
        actualTotalPrice: (map[DbConstants.colActualTotalPrice] as num? ?? 0)
            .toDouble(),
        note: map[DbConstants.colNote] as String?,
        priority: ItemPriorityX.fromString(
          map[DbConstants.colPriority] as String? ?? DbConstants.priorityNormal,
        ),
        sortOrder: map[DbConstants.colSortOrder] as int? ?? 0,
        isPurchased: (map[DbConstants.colIsPurchased] as int? ?? 0) == 1,
        createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
        updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colListId: listId,
    DbConstants.colName: name,
    DbConstants.colCategoryId: categoryId,
    DbConstants.colQuantity: quantity,
    DbConstants.colUnit: unit,
    DbConstants.colUnitPrice: unitPrice,
    DbConstants.colActualUnitPrice: actualUnitPrice,
    DbConstants.colTotalPrice: totalPrice,
    DbConstants.colActualTotalPrice: actualTotalPrice,
    DbConstants.colNote: note,
    DbConstants.colPriority: priority.value,
    DbConstants.colSortOrder: sortOrder,
    DbConstants.colIsPurchased: isPurchased ? 1 : 0,
    DbConstants.colCreatedAt: createdAt.toIso8601String(),
    DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
  };

  GroceryItemModel copyWith({
    int? id,
    int? listId,
    String? name,
    int? categoryId,
    String? categoryName,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? actualUnitPrice,
    double? totalPrice,
    double? actualTotalPrice,
    String? note,
    ItemPriority? priority,
    int? sortOrder,
    bool? isPurchased,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCategoryId = false,
    bool clearNote = false,
  }) => GroceryItemModel(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    name: name ?? this.name,
    categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
    categoryName: categoryName ?? this.categoryName,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    unitPrice: unitPrice ?? this.unitPrice,
    actualUnitPrice: actualUnitPrice ?? this.actualUnitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
    actualTotalPrice: actualTotalPrice ?? this.actualTotalPrice,
    note: clearNote ? null : (note ?? this.note),
    priority: priority ?? this.priority,
    sortOrder: sortOrder ?? this.sortOrder,
    isPurchased: isPurchased ?? this.isPurchased,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    listId,
    name,
    categoryId,
    quantity,
    unit,
    unitPrice,
    actualUnitPrice,
    totalPrice,
    actualTotalPrice,
    note,
    priority,
    sortOrder,
    isPurchased,
    createdAt,
    updatedAt,
  ];
}
