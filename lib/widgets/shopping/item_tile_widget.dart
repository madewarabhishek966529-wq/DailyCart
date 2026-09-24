import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/widgets/common/bouncy_tap.dart';

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
          return false;
        } else {
          // Swipe left: Delete
          HapticFeedback.mediumImpact();
          return true;
        }
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPurchased
                ? [AppColors.warning, const Color(0xFFFBBF24)]
                : [AppColors.primary, AppColors.primaryNeon],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isPurchased ? Icons.undo_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 26,
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
          gradient: const LinearGradient(
            colors: [Color(0xFFFB7185), AppColors.error],
          ),
          borderRadius: BorderRadius.circular(16),
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
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          ],
        ),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isPurchased ? 0.65 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? (isPurchased
                    ? const Color(0xFF0F1524)
                    : AppColors.cardDark)
                : (isPurchased
                    ? const Color(0xFFF1F5F9)
                    : Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? (isPurchased
                      ? const Color(0xFF192233)
                      : AppColors.borderDark)
                  : (isPurchased
                      ? const Color(0xFFE2E8F0)
                      : AppColors.borderLight),
              width: 1,
            ),
            boxShadow: isPurchased
                ? null
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Animated Checkbox
                    BouncyTap(
                      scaleFactor: 0.85,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTogglePurchased(!isPurchased);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: isPurchased
                              ? AppColors.primaryGradient
                              : null,
                          color: isPurchased ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPurchased
                                ? Colors.transparent
                                : (isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFCBD5E1)),
                            width: 2,
                          ),
                          boxShadow: isPurchased
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isPurchased
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),

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
                                    decorationColor: AppColors.textDisabled,
                                    color: isPurchased
                                        ? AppColors.textDisabled
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
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.priorityHigh
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.priorityHigh
                                          .withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.priority_high_rounded,
                                        size: 11,
                                        color: AppColors.priorityHigh,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'High',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.priorityHigh,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),

                          // Category and Note info
                          Row(
                            children: [
                              if (item.categoryName != null &&
                                  item.categoryName!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.categoryName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (item.note != null &&
                                    item.note!.trim().isNotEmpty)
                                  const SizedBox(width: 6),
                              ],
                              if (item.note != null &&
                                  item.note!.trim().isNotEmpty)
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
                    const SizedBox(width: 10),

                    // Stepper & Price Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Quantity Stepper
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStepperBtn(
                                icon: Icons.remove_rounded,
                                isDark: isDark,
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    onQuantityChanged(item.quantity - 1);
                                  } else if (item.quantity > 0.5) {
                                    onQuantityChanged(item.quantity - 0.5);
                                  }
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  '${FormatUtils.formatQuantity(item.quantity)} ${item.unit}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _buildStepperBtn(
                                icon: Icons.add_rounded,
                                isDark: isDark,
                                onPressed: () {
                                  onQuantityChanged(item.quantity + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Price display
                        if (item.unitPrice > 0 || item.actualUnitPrice > 0)
                          Text(
                            isPurchased && item.actualTotalPrice > 0
                                ? FormatUtils.formatCurrency(
                                    item.actualTotalPrice)
                                : FormatUtils.formatCurrency(item.totalPrice),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isPurchased
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.primaryLight
                                      : AppColors.primary),
                            ),
                          ),
                      ],
                    ),

                    if (showReorderHandle) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.drag_indicator_rounded,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return BouncyTap(
      scaleFactor: 0.88,
      onTap: onPressed,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 14,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
