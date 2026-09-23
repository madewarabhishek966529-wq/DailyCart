import 'package:flutter_test/flutter_test.dart';
import 'package:dailycart/models/category_model.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/models/shopping_history_model.dart';
import 'package:dailycart/models/shopping_list_model.dart';
import 'package:dailycart/models/template_item_model.dart';
import 'package:dailycart/models/template_model.dart';

void main() {
  group('Model Serialization & Calculations', () {
    test('ShoppingListModel budget calculations work correctly', () {
      final now = DateTime.now();
      final list = ShoppingListModel(
        id: 1,
        name: 'Weekly Grocery',
        budget: 2000,
        estimatedTotal: 1500,
        actualTotal: 1600,
        createdAt: now,
        updatedAt: now,
      );

      expect(list.hasBudget, isTrue);
      expect(list.isOverBudget, isFalse);
      expect(list.remainingBudget, 500);
      expect(list.costDifference, 100);

      final overBudgetList = list.copyWith(estimatedTotal: 2500);
      expect(overBudgetList.isOverBudget, isTrue);
      expect(overBudgetList.remainingBudget, -500);
    });

    test('ShoppingListModel toMap and fromMap roundtrip', () {
      final now = DateTime.parse('2026-09-23T12:00:00.000Z');
      final list = ShoppingListModel(
        id: 10,
        name: 'Party Supplies',
        budget: 5000,
        estimatedTotal: 3200,
        actualTotal: 3100,
        status: ListStatus.completed,
        createdAt: now,
        updatedAt: now,
        completedAt: now,
      );

      final map = list.toMap();
      final reconstructed = ShoppingListModel.fromMap(map);

      expect(reconstructed.id, 10);
      expect(reconstructed.name, 'Party Supplies');
      expect(reconstructed.budget, 5000);
      expect(reconstructed.status, ListStatus.completed);
      expect(reconstructed.completedAt, isNotNull);
    });

    test('GroceryItemModel toMap and fromMap roundtrip', () {
      final now = DateTime.parse('2026-09-23T12:00:00.000Z');
      final item = GroceryItemModel(
        id: 5,
        listId: 2,
        name: 'Almond Milk',
        categoryId: 3,
        quantity: 2.5,
        unit: 'litre',
        unitPrice: 120,
        actualUnitPrice: 115,
        totalPrice: 300,
        actualTotalPrice: 287.5,
        note: 'Unsweetened',
        priority: ItemPriority.high,
        sortOrder: 1,
        isPurchased: true,
        createdAt: now,
        updatedAt: now,
      );

      final map = item.toMap();
      final reconstructed = GroceryItemModel.fromMap(map);

      expect(reconstructed.id, 5);
      expect(reconstructed.name, 'Almond Milk');
      expect(reconstructed.quantity, 2.5);
      expect(reconstructed.unit, 'litre');
      expect(reconstructed.priority, ItemPriority.high);
      expect(reconstructed.isPurchased, isTrue);
      expect(reconstructed.note, 'Unsweetened');
    });

    test('CategoryModel serialization', () {
      final now = DateTime.parse('2026-09-23T12:00:00.000Z');
      final cat = CategoryModel(
        id: 1,
        name: 'Dairy',
        icon: '🥛',
        isDefault: true,
        createdAt: now,
      );

      final map = cat.toMap();
      final reconstructed = CategoryModel.fromMap(map);

      expect(reconstructed.name, 'Dairy');
      expect(reconstructed.icon, '🥛');
      expect(reconstructed.isDefault, isTrue);
    });

    test('ShoppingHistoryModel serialization', () {
      final now = DateTime.parse('2026-09-23T12:00:00.000Z');
      final history = ShoppingHistoryModel(
        id: 7,
        listName: 'Monthly Staples',
        totalAmount: 4500,
        itemCount: 22,
        completedAt: now,
      );

      final map = history.toMap();
      final reconstructed = ShoppingHistoryModel.fromMap(map);

      expect(reconstructed.listName, 'Monthly Staples');
      expect(reconstructed.totalAmount, 4500);
      expect(reconstructed.itemCount, 22);
    });

    test('Template and TemplateItem serialization', () {
      final now = DateTime.parse('2026-09-23T12:00:00.000Z');
      final template = TemplateModel(
        id: 2,
        name: 'Hostel Essentials',
        createdAt: now,
        updatedAt: now,
      );
      const item = TemplateItemModel(
        id: 1,
        templateId: 2,
        name: 'Instant Noodles',
        quantity: 5,
        unit: 'pack',
        defaultPrice: 15,
      );

      expect(template.name, 'Hostel Essentials');
      expect(item.quantity, 5);
      expect(item.unit, 'pack');
    });
  });
}
