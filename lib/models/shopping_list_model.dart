import 'package:equatable/equatable.dart';
import 'package:dailycart/core/database/database_constants.dart';

enum ListStatus { active, completed, archived }

extension ListStatusX on ListStatus {
  String get value {
    switch (this) {
      case ListStatus.active:
        return DbConstants.statusActive;
      case ListStatus.completed:
        return DbConstants.statusCompleted;
      case ListStatus.archived:
        return DbConstants.statusArchived;
    }
  }

  static ListStatus fromString(String s) {
    switch (s) {
      case DbConstants.statusCompleted:
        return ListStatus.completed;
      case DbConstants.statusArchived:
        return ListStatus.archived;
      default:
        return ListStatus.active;
    }
  }
}

class ShoppingListModel extends Equatable {
  const ShoppingListModel({
    this.id,
    required this.name,
    this.budget = 0,
    this.estimatedTotal = 0,
    this.actualTotal = 0,
    this.status = ListStatus.active,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.itemCount = 0,
    this.completedCount = 0,
  });
  final int? id;
  final String name;
  final double budget;
  final double estimatedTotal;
  final double actualTotal;
  final ListStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final int itemCount;
  final int completedCount;

  bool get hasBudget => budget > 0;
  bool get isOverBudget => hasBudget && estimatedTotal > budget;
  bool get isNearBudget =>
      hasBudget && estimatedTotal >= budget * 0.85 && !isOverBudget;
  double get remainingBudget => budget - estimatedTotal;
  double get costDifference => actualTotal - estimatedTotal;

  factory ShoppingListModel.fromMap(Map<String, dynamic> map) =>
      ShoppingListModel(
        id: map[DbConstants.colId] as int?,
        name: map[DbConstants.colName] as String,
        budget: (map[DbConstants.colBudget] as num? ?? 0).toDouble(),
        estimatedTotal: (map[DbConstants.colEstimatedTotal] as num? ?? 0)
            .toDouble(),
        actualTotal: (map[DbConstants.colActualTotal] as num? ?? 0).toDouble(),
        status: ListStatusX.fromString(
          map[DbConstants.colStatus] as String? ?? DbConstants.statusActive,
        ),
        createdAt: DateTime.parse(map[DbConstants.colCreatedAt] as String),
        updatedAt: DateTime.parse(map[DbConstants.colUpdatedAt] as String),
        completedAt: map[DbConstants.colCompletedAt] != null
            ? DateTime.parse(map[DbConstants.colCompletedAt] as String)
            : null,
        itemCount: map['item_count'] as int? ?? 0,
        completedCount: map['completed_count'] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) DbConstants.colId: id,
    DbConstants.colName: name,
    DbConstants.colBudget: budget,
    DbConstants.colEstimatedTotal: estimatedTotal,
    DbConstants.colActualTotal: actualTotal,
    DbConstants.colStatus: status.value,
    DbConstants.colCreatedAt: createdAt.toIso8601String(),
    DbConstants.colUpdatedAt: updatedAt.toIso8601String(),
    DbConstants.colCompletedAt: completedAt?.toIso8601String(),
  };

  ShoppingListModel copyWith({
    int? id,
    String? name,
    double? budget,
    double? estimatedTotal,
    double? actualTotal,
    ListStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? itemCount,
    int? completedCount,
    bool clearCompletedAt = false,
  }) => ShoppingListModel(
    id: id ?? this.id,
    name: name ?? this.name,
    budget: budget ?? this.budget,
    estimatedTotal: estimatedTotal ?? this.estimatedTotal,
    actualTotal: actualTotal ?? this.actualTotal,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    itemCount: itemCount ?? this.itemCount,
    completedCount: completedCount ?? this.completedCount,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    budget,
    estimatedTotal,
    actualTotal,
    status,
    createdAt,
    updatedAt,
    completedAt,
    itemCount,
    completedCount,
  ];
}
