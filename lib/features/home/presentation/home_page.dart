import 'package:flutter/material.dart';

import '../../qr/presentation/qr_scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Искать в Malina',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _QrBanner(onTap: () => _openScanner(context)),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _CategoryBox(
                title: 'Еда',
                desc: 'Из кафе и\nресторанов',
                color: const Color(0xFFFFE4A1),
                img: 'assets/foodBanner.png',
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _CategoryBox(
                title: 'Бьюти',
                desc: 'Салоны красоты\nи товары',
                color: const Color(0xFFFFE4E1),
                img: 'assets/beautyBanner.png',
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Скоро в Malina',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _SoonList()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _openScanner(BuildContext context) async {
    final res = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(),
        fullscreenDialog: true,
      ),
    );
    if (res != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR-код успешно отсканирован')),
      );
    }
  }
}

class _QrBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _QrBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF62C5B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/Frame.png',
                width: 36,
                height: 50,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.qr_code, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Сканируй QR-код и заказывай прямо в заведении',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBox extends StatelessWidget {
  final String title, desc, img;
  final Color color;

  const _CategoryBox({
    required this.title,
    required this.desc,
    required this.color,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoonList extends StatelessWidget {
  const _SoonList();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Вакансии', Colors.blue[50]),
      ('Маркет', Colors.orange[50]),
      ('Цветы', Colors.pink[50]),
      ('Медицина', Colors.green[50]),
    ];
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (c, i) => Container(
          width: 85,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: items[i].$2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              items[i].$1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
