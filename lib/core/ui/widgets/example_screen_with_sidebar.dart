import 'package:flutter/material.dart';
import 'category_sidebar.dart';
import 'custom_bottom_nav_bar.dart';

/// Пример экрана с боковой панелью категорий и нижним TabBar
class ExampleScreenWithSidebar extends StatefulWidget {
  const ExampleScreenWithSidebar({super.key});

  @override
  State<ExampleScreenWithSidebar> createState() =>
      _ExampleScreenWithSidebarState();
}

class _ExampleScreenWithSidebarState extends State<ExampleScreenWithSidebar> {
  int _selectedBottomIndex = 0;
  String _selectedCategory = 'food';

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithCategorySidebar(
      appBar: AppBar(
        title: const Text('Лента'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      categories: [
        CategoryItem(
          id: 'food',
          label: 'Еда',
          icon: Icons.restaurant,
          isSelected: _selectedCategory == 'food',
          onTap: () {
            setState(() => _selectedCategory = 'food');
          },
        ),
        CategoryItem(
          id: 'beauty',
          label: 'Бьюти',
          icon: Icons.spa,
          count: 1,
          isSelected: _selectedCategory == 'beauty',
          onTap: () {
            setState(() => _selectedCategory = 'beauty');
          },
        ),
      ],
      bottomNavigationBar: MalinaBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemTapped: (index) {
          setState(() => _selectedBottomIndex = index);
          // Навигация по страницам
          _handleBottomNavigation(index);
        },
        onCenterPressed: () {
          // Обработка нажатия на центральную кнопку
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Центральная кнопка нажата')),
          );
        },
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Содержимое: ${_selectedCategory == 'food' ? 'Еда' : 'Бьюти'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Здесь может быть любой контент
              Container(
                height: 400,
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    'Контент категории: ${_selectedCategory == 'food' ? 'Еда' : 'Бьюти'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        // Лента
        break;
      case 1:
        // Избранное
        break;
      case 2:
        // Профиль
        break;
      case 3:
        // Корзина
        break;
    }
  }
}
