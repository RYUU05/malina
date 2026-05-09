import 'package:flutter/material.dart';

/// Модель для категории в боковой панели
class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    this.count = 0,
    this.isSelected = false,
    required this.onTap,
  });
}

/// Боковая плавающая панель категорий
/// Расположена в правом краю экрана, не блокирует контент
class CategorySidebar extends StatelessWidget {
  final List<CategoryItem> categories;
  final EdgeInsets padding;

  const CategorySidebar({
    Key? key,
    required this.categories,
    this.padding = const EdgeInsets.only(top: 20, right: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: padding.top,
      child: Padding(
        padding: EdgeInsets.only(right: padding.right),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < categories.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < categories.length - 1 ? 16 : 0,
                ),
                child: _CategoryCard(item: categories[i]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Карточка категории для боковой панели
class _CategoryCard extends StatelessWidget {
  final CategoryItem item;

  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
              border: item.isSelected
                  ? Border.all(color: const Color(0xFFF62C5B), width: 2)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 28,
                  color: item.isSelected
                      ? const Color(0xFFF62C5B)
                      : Colors.grey.shade600,
                ),
              ],
            ),
          ),
          // Текст ниже карточки
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          // Бейдж счётчика
          if (item.count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF62C5B),
                ),
                child: Center(
                  child: Text(
                    item.count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Обёртка Stack для размещения контента + боковой панели
class ScaffoldWithCategorySidebar extends StatelessWidget {
  final Widget child;
  final List<CategoryItem> categories;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final EdgeInsets sidebarPadding;

  const ScaffoldWithCategorySidebar({
    Key? key,
    required this.child,
    required this.categories,
    this.appBar,
    this.bottomNavigationBar,
    this.sidebarPadding = const EdgeInsets.only(top: 20, right: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          child,
          CategorySidebar(categories: categories, padding: sidebarPadding),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
