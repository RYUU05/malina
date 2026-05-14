import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../domain/cart_item.dart';

class CartPage extends StatefulWidget {
  final String? categoryFilter;

  const CartPage({super.key, this.categoryFilter});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  static const _pink = Color(0xFFF62C5B);
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryFilter == 'beauty'
        ? Category.beauty
        : Category.food;
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryFilter != widget.categoryFilter) {
      setState(() {
        _selectedCategory = widget.categoryFilter == 'beauty'
            ? Category.beauty
            : Category.food;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _CategoryTabs(
                selected: _selectedCategory,
                onChanged: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),
            Expanded(child: _CartList(category: _selectedCategory)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-item'),
        backgroundColor: const Color(0xFFF0E7F8),
        foregroundColor: const Color(0xFF5E5196),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 24, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/feed'),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: const Color(0xFF222222),
          ),
          const Expanded(
            child: Text(
              'Корзина',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _clearCart(context),
            child: const Text(
              'Очистить',
              style: TextStyle(color: Color(0xFF222222), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const CartCleared());
              Navigator.pop(ctx);
            },
            child: const Text('Да', style: TextStyle(color: _pink)),
          ),
        ],
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final Category selected;
  final ValueChanged<Category> onChanged;

  const _CategoryTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _tab(
            label: 'Еда',
            active: selected == Category.food,
            cat: Category.food,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _tab(
            label: 'Бьюти',
            active: selected == Category.beauty,
            cat: Category.beauty,
          ),
        ),
      ],
    );
  }

  Widget _tab({
    required String label,
    required bool active,
    required Category cat,
  }) {
    return GestureDetector(
      onTap: () => onChanged(cat),
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF62C5B) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: active ? null : Border.all(color: const Color(0xFFE7E7E7)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF4A4A4A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CartList extends StatelessWidget {
  final Category category;
  const _CartList({required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final filtered = state.items
            .where((i) => i.category == category)
            .toList();
        if (filtered.isEmpty) return const _EmptyView();

        final groups = <String, List<CartItem>>{};
        for (var item in filtered) {
          final key =
              item.subcategory ?? (category == Category.food ? 'Еда' : 'Бьюти');
          groups.putIfAbsent(key, () => []).add(item);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: groups.entries
              .map((e) => _GroupCard(title: e.key, items: e.value))
              .toList(),
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String title;
  final List<CartItem> items;

  const _GroupCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final total = items.fold(
      0,
      (sum, i) => sum + ((i.price ?? 0) * i.quantity),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const Divider(),
          ...items.map((i) => _ItemRow(item: i)),
          const SizedBox(height: 16),
          _TotalButton(total: total),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImagePlaceholder(cat: item.category),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${item.price ?? 0} С',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _QtySelector(item: item),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Category cat;
  const _ImagePlaceholder({required this.cat});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        cat == Category.food ? Icons.fastfood : Icons.face,
        color: Colors.grey,
      ),
    );
  }
}

class _QtySelector extends StatelessWidget {
  final CartItem item;
  const _QtySelector({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove, () => _change(-1, context)),
        SizedBox(
          width: 30,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _btn(Icons.add, () => _change(1, context)),
        const Spacer(),
        IconButton(
          onPressed: () =>
              context.read<CartBloc>().add(CartItemRemoved(item.id)),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
    );
  }

  void _change(int d, BuildContext context) {
    context.read<CartBloc>().add(
      CartItemQuantityChanged(itemId: item.id, delta: d),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _TotalButton extends StatelessWidget {
  final int total;
  const _TotalButton({required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF62C5B),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'Всего $total С',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Пусто', style: TextStyle(color: Colors.grey)),
    );
  }
}
