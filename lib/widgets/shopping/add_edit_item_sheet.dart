import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailycart/core/constants/app_constants.dart';
import 'package:dailycart/core/theme/app_colors.dart';
import 'package:dailycart/core/utils/format_utils.dart';
import 'package:dailycart/models/category_model.dart';
import 'package:dailycart/models/grocery_item_model.dart';
import 'package:dailycart/providers/category_provider.dart';
import 'package:dailycart/providers/frequent_item_provider.dart';
import 'package:dailycart/providers/grocery_item_provider.dart';
import 'package:dailycart/providers/shopping_list_provider.dart';

class AddEditItemSheet extends ConsumerStatefulWidget {
  const AddEditItemSheet({super.key, required this.listId, this.existingItem});

  final int listId;
  final GroceryItemModel? existingItem;

  static Future<void> show(
    BuildContext context, {
    required int listId,
    GroceryItemModel? existingItem,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          AddEditItemSheet(listId: listId, existingItem: existingItem),
    );
  }

  @override
  ConsumerState<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends ConsumerState<AddEditItemSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _actualUnitPriceController;
  late final TextEditingController _noteController;

  int? _selectedCategoryId;
  String _selectedUnit = 'piece';
  ItemPriority _selectedPriority = ItemPriority.normal;
  double _quantity = 1.0;
  double _unitPrice = 0.0;
  double _actualUnitPrice = 0.0;

  bool get isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantity = item?.quantity ?? 1.0;
    _quantityController = TextEditingController(
      text: FormatUtils.formatQuantity(_quantity),
    );
    _selectedUnit = item?.unit ?? 'piece';
    _unitPrice = item?.unitPrice ?? 0.0;
    _unitPriceController = TextEditingController(
      text: _unitPrice > 0 ? _unitPrice.toStringAsFixed(2) : '',
    );
    _actualUnitPrice = item?.actualUnitPrice ?? 0.0;
    _actualUnitPriceController = TextEditingController(
      text: _actualUnitPrice > 0 ? _actualUnitPrice.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: item?.note ?? '');
    _selectedCategoryId = item?.categoryId;
    _selectedPriority = item?.priority ?? ItemPriority.normal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _actualUnitPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateQuantity(double newQty) {
    if (newQty <= 0) return;
    setState(() {
      _quantity = newQty;
      _quantityController.text = FormatUtils.formatQuantity(_quantity);
    });
  }

  double get _calculatedEstimatedTotal => _quantity * _unitPrice;
  double get _calculatedActualTotal =>
      _quantity * (_actualUnitPrice > 0 ? _actualUnitPrice : _unitPrice);

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pinned Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isEdit
                                ? Icons.edit_note_rounded
                                : Icons.add_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEdit ? 'Edit Item' : 'Add Grocery Item',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: isDark ? Colors.white10 : Colors.black12,
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name with suggestions
                    TextField(
                      controller: _nameController,
                      autofocus: !isEdit,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText: 'e.g. Fresh Milk, Tomatoes, Brown Bread',
                        prefixIcon: Icon(
                          Icons.shopping_basket_outlined,
                          size: 20,
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),

                    // Quick suggestion chips based on input
                    if (!isEdit && _nameController.text.isNotEmpty)
                      _buildSuggestionsRow(),

                    const SizedBox(height: 16),

                    // Category selector
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) =>
                          _buildCategoryChips(categories, isDark),
                      loading: () => const SizedBox(
                        height: 32,
                        child: LinearProgressIndicator(),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity Stepper
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Quantity',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildStepperAction(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (_quantity > 1) {
                                        _updateQuantity(_quantity - 1);
                                      } else if (_quantity > 0.25) {
                                        _updateQuantity(_quantity - 0.25);
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _quantityController,
                                      textAlign: TextAlign.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        final d = double.tryParse(val);
                                        if (d != null && d > 0) {
                                          _quantity = d;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  _buildStepperAction(
                                    icon: Icons.add,
                                    onTap: () => _updateQuantity(_quantity + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Unit Selector
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unit',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedUnit,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: AppConstants.units.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedUnit = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price Fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Unit Price',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _unitPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  prefixText: '${AppConstants.currency} ',
                                  hintText: '0.00',
                                ),
                                onChanged: (val) {
                                  _unitPrice = double.tryParse(val) ?? 0.0;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        if (isEdit && widget.existingItem!.isPurchased) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Actual Price',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _actualUnitPriceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    prefixText: '${AppConstants.currency} ',
                                    hintText: '0.00',
                                  ),
                                  onChanged: (val) {
                                    _actualUnitPrice =
                                        double.tryParse(val) ?? 0.0;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (_unitPrice > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Total: ${FormatUtils.formatCurrency(_calculatedEstimatedTotal)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Note field
                    TextField(
                      controller: _noteController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Note / Brand (Optional)',
                        hintText: 'e.g. Amul Gold, 2 packs',
                        prefixIcon: Icon(Icons.notes_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Priority Selector
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityChip('Normal', ItemPriority.normal),
                        const SizedBox(width: 8),
                        _buildPriorityChip('High', ItemPriority.high),
                        const SizedBox(width: 8),
                        _buildPriorityChip('Low', ItemPriority.low),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Pinned Bottom Action Button (Never floats or overlaps)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 0.8,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveItem,
                    icon: Icon(
                      isEdit
                          ? Icons.check_circle_outline_rounded
                          : Icons.add_shopping_cart_rounded,
                      size: 20,
                    ),
                    label: Text(
                      isEdit ? 'Save Changes' : 'Add to List',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsRow() {
    final searchAsync = ref.watch(
      frequentItemSearchProvider(_nameController.text),
    );

    return searchAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.take(5).map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(f.name),
                    onPressed: () {
                      _nameController.text = f.name;
                      _quantity = f.defaultQuantity;
                      _quantityController.text = FormatUtils.formatQuantity(
                        _quantity,
                      );
                      _selectedUnit = f.defaultUnit;
                      _unitPrice = f.defaultPrice;
                      _unitPriceController.text = _unitPrice > 0
                          ? _unitPrice.toStringAsFixed(2)
                          : '';
                      if (f.categoryId != null) {
                        _selectedCategoryId = f.categoryId;
                      }
                      setState(() {});
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildCategoryChips(List<CategoryModel> categories, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategoryId == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              avatar: cat.icon != null ? Text(cat.icon!) : null,
              label: Text(cat.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = selected ? cat.id : null;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepperAction({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20, color: AppColors.primary),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildPriorityChip(String label, ItemPriority priority) {
    final isSelected = _selectedPriority == priority;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (sel) {
        if (sel) setState(() => _selectedPriority = priority);
      },
    );
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name.')),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final now = DateTime.now();

    if (isEdit) {
      final updated = widget.existingItem!.copyWith(
        name: name,
        categoryId: _selectedCategoryId,
        clearCategoryId: _selectedCategoryId == null,
        quantity: _quantity,
        unit: _selectedUnit,
        unitPrice: _unitPrice,
        actualUnitPrice: _actualUnitPrice,
        totalPrice: _calculatedEstimatedTotal,
        actualTotalPrice: _calculatedActualTotal,
        note: _noteController.text.trim(),
        clearNote: _noteController.text.trim().isEmpty,
        priority: _selectedPriority,
        updatedAt: now,
      );
      await ref
          .read(groceryItemsProvider(widget.listId).notifier)
          .updateItem(updated);
    } else {
      final newItem = GroceryItemModel(
        listId: widget.listId,
        name: name,
        categoryId: _selectedCategoryId,
        quantity: _quantity,
        unit: _selectedUnit,
        unitPrice: _unitPrice,
        actualUnitPrice: 0,
        totalPrice: _calculatedEstimatedTotal,
        actualTotalPrice: 0,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        priority: _selectedPriority,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(groceryItemsProvider(widget.listId).notifier).add(newItem);
    }

    ref.invalidate(shoppingListsProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
