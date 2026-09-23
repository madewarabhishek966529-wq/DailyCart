import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/grocery_item_model.dart';

class ItemTileWidget extends StatelessWidget {
  const ItemTileWidget({
    super.key,
    required this.item,
    required this.onTogglePurchased,
    required this.onTap,
    required this.onDelete,
    required this.onQuantityChanged,
    this.showReorderHandle = false,
  });

  final GroceryItemModel item;
  final ValueChanged<bool> onTogglePurchased;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<double> onQuantityChanged;
  final bool showReorderHandle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPurchased = item.isPurchased;

    return Dismissible(
      key: ValueKey('item_${item.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right: Toggle purchase
          HapticFeedback.lightImpact();
          onTogglePurchased(!isPurchased);
          return false; // don't dismiss from tree, state change moves it
        } else {
          // Swipe left: Delete
          HapticFeedback.mediumImpact();
          return true; // proceed to onDismissed
        }
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isPurchased ? AppColors.warning : AppColors.success,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              isPurchased ? Icons.undo_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isPurchased ? 'To Buy' : 'Purchased',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
          ],
        ),
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE8E8E8),
            width: 0.8,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Animated Checkbox
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTogglePurchased(!isPurchased);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isPurchased
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPurchased
                            ? AppColors.primary
                            : (isDark ? Colors.white38 : Colors.black26),
                        width: 2,
                      ),
                    ),
                    child: isPurchased
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Name, Category, Note, Priority
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isPurchased
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isPurchased
                                    ? (isDark
                                          ? AppColors.textDisabled
                                          : AppColors.textDisabled)
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.priority == ItemPriority.high)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                color: AppColors.priorityHigh.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'High',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.priorityHigh,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Category and Note info
                      Row(
                        children: [
                          if (item.categoryName != null &&
                              item.categoryName!.isNotEmpty) ...[
                            Text(
                              item.categoryName!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            if (item.note != null &&
                                item.note!.trim().isNotEmpty)
                              Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                          ],
                          if (item.note != null && item.note!.trim().isNotEmpty)
                            Expanded(
                              child: Text(
                                item.note!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Stepper & Price Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Quantity Stepper: [−] 1 piece [+]
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStepperBtn(
                          icon: Icons.remove,
                          onPressed: () {
                            if (item.quantity > 1) {
                              onQuantityChanged(item.quantity - 1);
                            } else if (item.quantity > 0.5) {
                              onQuantityChanged(item.quantity - 0.5);
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${FormatUtils.formatQuantity(item.quantity)} ${item.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildStepperBtn(
                          icon: Icons.add,
                          onPressed: () {
                            onQuantityChanged(item.quantity + 1);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Price display
                    if (item.unitPrice > 0 || item.actualUnitPrice > 0)
                      Text(
                        isPurchased && item.actualTotalPrice > 0
                            ? FormatUtils.formatCurrency(item.actualTotalPrice)
                            : FormatUtils.formatCurrency(item.totalPrice),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPurchased
                              ? AppColors.success
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary),
                        ),
                      ),
                  ],
                ),

                if (showReorderHandle) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.drag_indicator_rounded, color: Colors.grey),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 24,
      height: 24,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 15,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}
