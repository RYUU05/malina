import 'package:flutter/material.dart';
import 'category_sidebar.dart';
import 'custom_bottom_nav_bar.dart';

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
          onTap: () => setState(() => _selectedCategory = 'food'),
        ),
        CategoryItem(
          id: 'beauty',
          label: 'Бьюти',
          icon: Icons.spa,
          count: 1,
          isSelected: _selectedCategory == 'beauty',
          onTap: () => setState(() => _selectedCategory = 'beauty'),
        ),
      ],
      bottomNavigationBar: MalinaBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemTapped: (index) {
          setState(() => _selectedBottomIndex = index);
          _onNavTap(index);
        },
        onCenterPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR')),
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
                _selectedCategory == 'food' ? 'Еда' : 'Бьюти',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 400,
                color: Colors.grey.shade200,
                child: Center(
                  child: Text(
                    _selectedCategory,
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

  void _onNavTap(int index) {
    // TODO: навигация
  }
}
