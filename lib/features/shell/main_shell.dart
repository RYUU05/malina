import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:malina/features/cart/domain/entities/cart_item.dart';

import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';
import '../cart/bloc/cart_bloc.dart';
import '../cart/bloc/cart_state.dart';
import '../qr/presentation/qr_scanner_page.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cartCategoryMenuController;
  bool _isCartCategoryMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _cartCategoryMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _cartCategoryMenuController.dispose();
    super.dispose();
  }

  Future<void> _openQrScanner(BuildContext context) async {
    final scannedCode = await Navigator.of(context, rootNavigator: true)
        .push<String>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => const QrScannerPage(),
          ),
        );

    if (!context.mounted || scannedCode == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR-код отсканирован')));
  }

  void _showCartCategoryMenu() {
    if (_isCartCategoryMenuVisible) return;

    setState(() => _isCartCategoryMenuVisible = true);
    _cartCategoryMenuController.forward(from: 0);
  }

  Future<void> _hideCartCategoryMenu() async {
    if (!_isCartCategoryMenuVisible) return;

    await _cartCategoryMenuController.reverse();
    if (!mounted) return;

    setState(() => _isCartCategoryMenuVisible = false);
  }

  Future<void> _openCartWithCategory(Category category) async {
    await _hideCartCategoryMenu();
    if (!mounted) return;

    final categoryName = category == Category.beauty ? 'beauty' : 'food';
    context.go('/cart?category=$categoryName');
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        _hideCartCategoryMenu();
        context.go('/feed');
      case 1:
        _hideCartCategoryMenu();
        context.go('/favorites');
      case 2:
        _hideCartCategoryMenu();
        _openQrScanner(context);
      case 3:
        _hideCartCategoryMenu();
        context.go('/profile');
      case 4:
        if (_isCartCategoryMenuVisible) {
          _hideCartCategoryMenu();
        } else {
          _showCartCategoryMenu();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final showNav = authState.status == AuthStatus.authenticated;

        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final beautyCount = cartState.items
                .where((i) => i.category == Category.beauty)
                .length;

            return Scaffold(
              body: Stack(
                children: [
                  widget.child,
                  if (showNav && _isCartCategoryMenuVisible)
                    _CartCategorySelectorOverlay(
                      controller: _cartCategoryMenuController,
                      beautyCount: beautyCount,
                      onDismiss: _hideCartCategoryMenu,
                      onFoodTap: () => _openCartWithCategory(Category.food),
                      onBeautyTap: () => _openCartWithCategory(Category.beauty),
                    ),
                ],
              ),
              bottomNavigationBar: showNav
                  ? BottomNavigationBar(
                      currentIndex: widget.currentIndex,
                      onTap: (index) => _onItemTapped(context, index),
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: const Color(0xFFF62C5B),
                      unselectedItemColor: Colors.grey,
                      items: [
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.storefront),
                          label: 'Лента',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.favorite_outline),
                          label: 'Избранное',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF62C5B),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                          ),
                          label: '',
                        ),
                        const BottomNavigationBarItem(
                          icon: Icon(Icons.person_outline),
                          label: 'Профиль',
                        ),
                        BottomNavigationBarItem(
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.grey,
                              ),
                              if (cartState.items.isNotEmpty)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF62C5B),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${cartState.items.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          label: 'Корзина',
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

class _CartCategorySelectorOverlay extends StatelessWidget {
  final AnimationController controller;
  final int beautyCount;
  final VoidCallback onDismiss;
  final VoidCallback onFoodTap;
  final VoidCallback onBeautyTap;

  const _CartCategorySelectorOverlay({
    required this.controller,
    required this.beautyCount,
    required this.onDismiss,
    required this.onFoodTap,
    required this.onBeautyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDismiss,
                      child: ColoredBox(
                        color: Colors.black.withValues(
                          alpha: 0.15 * controller.value,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                right: 7,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedCartCategoryOption(
                      controller: controller,
                      animationStart: 0.22,
                      icon: Icons.restaurant,
                      label: 'Еда',
                      onTap: onFoodTap,
                    ),
                    const SizedBox(height: 18),
                    _AnimatedCartCategoryOption(
                      controller: controller,
                      animationStart: 0,
                      icon: Icons.spa,
                      label: 'Бьюти',
                      badgeCount: beautyCount,
                      onTap: onBeautyTap,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedCartCategoryOption extends StatelessWidget {
  final AnimationController controller;
  final double animationStart;
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _AnimatedCartCategoryOption({
    required this.controller,
    required this.animationStart,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: _CartCategoryBubble(
        icon: icon,
        label: label,
        badgeCount: badgeCount,
        onTap: onTap,
      ),
      builder: (context, child) {
        final rawProgress =
            ((controller.value - animationStart) / (1 - animationStart)).clamp(
              0.0,
              1.0,
            );
        final slideProgress = Curves.easeOutBack.transform(rawProgress);
        final fadeProgress = Curves.easeOut.transform(rawProgress);

        return Opacity(
          opacity: fadeProgress,
          child: Transform.translate(
            offset: Offset(0, (1 - slideProgress) * 26),
            child: child,
          ),
        );
      },
    );
  }
}

class _CartCategoryBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _CartCategoryBubble({
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black87, size: 28),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2A2A2A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0154A),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
