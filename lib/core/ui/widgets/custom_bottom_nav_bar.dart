import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final VoidCallback? onCenterButtonPressed;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    this.onCenterButtonPressed,
    this.activeColor = const Color(0xFFF62C5B),
    this.inactiveColor = const Color(0xFF999999),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              item: items[0],
              color: items[0].isActive ? activeColor : inactiveColor,
            ),
            _NavBarItem(
              item: items[1],
              color: items[1].isActive ? activeColor : inactiveColor,
            ),
            GestureDetector(
              onTap: onCenterButtonPressed,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.apps, color: Colors.white, size: 24),
              ),
            ),
            _NavBarItem(
              item: items[2],
              color: items[2].isActive ? activeColor : inactiveColor,
            ),
            _NavBarItem(
              item: items[3],
              color: items[3].isActive ? activeColor : inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  BottomNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });
}

class _NavBarItem extends StatelessWidget {
  final BottomNavItem item;
  final Color color;

  const _NavBarItem({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class MalinaBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback? onCenterPressed;

  const MalinaBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onCenterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      items: [
        BottomNavItem(
          label: 'Лента',
          icon: Icons.feed,
          onTap: () => onItemTapped(0),
          isActive: selectedIndex == 0,
        ),
        BottomNavItem(
          label: 'Избранное',
          icon: Icons.favorite_border,
          onTap: () => onItemTapped(1),
          isActive: selectedIndex == 1,
        ),
        BottomNavItem(
          label: 'Профиль',
          icon: Icons.person_outline,
          onTap: () => onItemTapped(2),
          isActive: selectedIndex == 2,
        ),
        BottomNavItem(
          label: 'Корзина',
          icon: Icons.shopping_cart_outlined,
          onTap: () => onItemTapped(3),
          isActive: selectedIndex == 3,
        ),
      ],
      onCenterButtonPressed: onCenterPressed,
    );
  }
}
