import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

class ShoppingHistoryModel extends Equatable {
  const ShoppingHistoryModel({
    this.id,
    required this.listName,
    this.totalAmount = 0,
    this.itemCount = 0,
    required this.completedAt,
  });
  final int? id;
  final String listName;
  final double totalAmount;
  final int itemCount;
  final DateTime completedAt;

  factory ShoppingHistoryModel.fromMap(Map<String, dynamic> map) =>
      ShoppingHistoryModel(
        id: map[DbConstants.colId] as int?,
        listName: map[DbConstants.colListName] as String,
        totalAmount: (map[DbConstants.colTotalAmount] as num? ?? 0).toDouble(),
        itemCount: map[DbConstants.colItemCount] as int? ?? 0,
        completedAt: DateTime.parse(map[DbConstants.colCompletedAt] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colListName: listName,
    DbConstants.colTotalAmount: totalAmount,
    DbConstants.colItemCount: itemCount,
    DbConstants.colCompletedAt: completedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    listName,
    totalAmount,
    itemCount,
    completedAt,
  ];
}
