import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../data/cart_repository.dart';
import '../data/models/cart_item.dart';

class CartPage extends StatefulWidget {
  final String? categoryFilter;

  const CartPage({super.key, this.categoryFilter});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const _accentColor = Color(0xFFF62C5B);

  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categoryFromFilter(widget.categoryFilter);
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryFilter != widget.categoryFilter) {
      _selectedCategory = _categoryFromFilter(widget.categoryFilter);
    }
  }

  Category _categoryFromFilter(String? filter) {
    return filter == 'beauty' ? Category.beauty : Category.food;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 24, 14),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/feed'),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: const Color(0xFF222222),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Корзина',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showClearCartDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF222222),
                    ),
                    child: const Text(
                      'Очистить',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _CategorySegmentedControl(
                selectedCategory: _selectedCategory,
                onChanged: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
            ),
            Expanded(child: _CartContent(category: _selectedCategory)),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: () => context.push('/add-item'),
          elevation: 8,
          backgroundColor: const Color(0xFFF0E7F8),
          foregroundColor: const Color(0xFF5E5196),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.add, size: 34),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    final cartBloc = context.read<CartBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить корзину'),
        content: const Text('Удалить все товары из корзины?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final username = cartBloc.state.username;
              context.read<CartRepository>().clearCart(username);
              cartBloc.add(CartLoaded(username));
            },
            child: const Text('Удалить', style: TextStyle(color: _accentColor)),
          ),
        ],
      ),
    );
  }
}

class _CategorySegmentedControl extends StatelessWidget {
  final Category selectedCategory;
  final ValueChanged<Category> onChanged;

  const _CategorySegmentedControl({
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CategorySegment(
            label: 'Еда',
            isSelected: selectedCategory == Category.food,
            onTap: () => onChanged(Category.food),
          ),
        ),
        const SizedBox(width: 22),
        Expanded(
          child: _CategorySegment(
            label: 'Бьюти',
            isSelected: selectedCategory == Category.beauty,
            onTap: () => onChanged(Category.beauty),
          ),
        ),
      ],
    );
  }
}

class _CategorySegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategorySegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF62C5B) : Colors.white,
          borderRadius: BorderRadius.circular(29),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE7E7E7), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A4A4A),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  final Category category;

  const _CartContent({required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final items = state.items.where((i) => i.category == category).toList();

        if (items.isEmpty) {
          return _EmptyCart(category: category);
        }

        final groups = _groupItems(items);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 112),
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: 24),
          itemBuilder: (context, index) {
            return _CartGroupCard(group: groups[index]);
          },
        );
      },
    );
  }

  List<_CartGroupData> _groupItems(List<CartItem> items) {
    final grouped = <String, List<CartItem>>{};

    for (final item in items) {
      final title = _groupTitle(item);
      grouped.putIfAbsent(title, () => []).add(item);
    }

    return grouped.entries
        .map((entry) => _CartGroupData(title: entry.key, items: entry.value))
        .toList();
  }

  String _groupTitle(CartItem item) {
    final subcategory = item.subcategory?.trim();
    if (subcategory != null && subcategory.isNotEmpty) return subcategory;

    return item.category == Category.beauty ? 'Hair' : 'Еда';
  }
}

class _CartGroupData {
  final String title;
  final List<CartItem> items;

  const _CartGroupData({required this.title, required this.items});

  int get total =>
      items.fold(0, (sum, item) => sum + ((item.price ?? 0) * item.quantity));
}

class _CartGroupCard extends StatelessWidget {
  final _CartGroupData group;

  const _CartGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.title,
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF707070),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE7E7E7)),
          const SizedBox(height: 18),
          for (var index = 0; index < group.items.length; index++) ...[
            _CartProductRow(item: group.items[index]),
            if (index != group.items.length - 1) const SizedBox(height: 26),
          ],
          const SizedBox(height: 24),
          _TotalBar(total: group.total),
        ],
      ),
    );
  }
}

class _CartProductRow extends StatelessWidget {
  final CartItem item;

  const _CartProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProductPreview(category: item.category),
        const SizedBox(width: 14),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 124),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.05,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatPrice(item.price ?? 0),
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description?.trim().isNotEmpty == true
                      ? item.description!.trim()
                      : _fallbackDescription(item.category),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 14,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => context.read<CartBloc>().add(
                        CartItemQuantityChanged(itemId: item.id, delta: -1),
                      ),
                    ),
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => context.read<CartBloc>().add(
                        CartItemQuantityChanged(itemId: item.id, delta: 1),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => context.read<CartBloc>().add(
                        CartItemRemoved(item.id),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      color: const Color(0xFF222222),
                      iconSize: 26,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatPrice(int price) => '$price C';

  String _fallbackDescription(Category category) {
    return category == Category.beauty ? 'Описание товара' : 'Описание блюда';
  }
}

class _ProductPreview extends StatelessWidget {
  final Category category;

  const _ProductPreview({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            category == Category.beauty
                ? 'assets/shampoo.png'
                : 'assets/pizza.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF222222), size: 24),
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  final int total;

  const _TotalBar({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFF62C5B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Всего',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$total C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final Category category;

  const _EmptyCart({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 82,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 18),
            Text(
              category == Category.beauty
                  ? 'В бьюти-корзине пока пусто'
                  : 'В корзине еды пока пусто',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
