// DailyCart - Database Constants
class DbConstants {
  DbConstants._();

  static const String dbName = 'dailycart.db';
  static const int dbVersion = 1;

  // Table names
  static const String tableShoppingLists = 'shopping_lists';
  static const String tableGroceryItems = 'grocery_items';
  static const String tableCategories = 'categories';
  static const String tableFrequentItems = 'frequent_items';
  static const String tableShoppingHistory = 'shopping_history';
  static const String tablePriceHistory = 'price_history';
  static const String tableTemplates = 'templates';
  static const String tableTemplateItems = 'template_items';

  // Common columns
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // shopping_lists columns
  static const String colBudget = 'budget';
  static const String colEstimatedTotal = 'estimated_total';
  static const String colActualTotal = 'actual_total';
  static const String colStatus = 'status';
  static const String colCompletedAt = 'completed_at';

  // grocery_items columns
  static const String colListId = 'list_id';
  static const String colCategoryId = 'category_id';
  static const String colQuantity = 'quantity';
  static const String colUnit = 'unit';
  static const String colUnitPrice = 'unit_price';
  static const String colActualUnitPrice = 'actual_unit_price';
  static const String colTotalPrice = 'total_price';
  static const String colActualTotalPrice = 'actual_total_price';
  static const String colNote = 'note';
  static const String colPriority = 'priority';
  static const String colSortOrder = 'sort_order';
  static const String colIsPurchased = 'is_purchased';

  // categories columns
  static const String colIcon = 'icon';
  static const String colIsDefault = 'is_default';

  // frequent_items columns
  static const String colDefaultQuantity = 'default_quantity';
  static const String colDefaultUnit = 'default_unit';
  static const String colDefaultPrice = 'default_price';
  static const String colUsageCount = 'usage_count';
  static const String colLastUsedAt = 'last_used_at';

  // shopping_history columns
  static const String colListName = 'list_name';
  static const String colTotalAmount = 'total_amount';
  static const String colItemCount = 'item_count';

  // price_history columns
  static const String colItemName = 'item_name';
  static const String colPrice = 'price';
  static const String colRecordedAt = 'recorded_at';

  // template_items columns
  static const String colTemplateId = 'template_id';

  // Status values
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  // Priority values
  static const String priorityLow = 'low';
  static const String priorityNormal = 'normal';
  static const String priorityHigh = 'high';
}
