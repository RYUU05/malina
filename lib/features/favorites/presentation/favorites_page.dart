import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:malina/core/di/injection.dart';
import 'package:malina/features/favorites/bloc/favorites_bloc.dart';
import 'package:malina/features/favorites/domain/favorite_item.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<FavoritesBloc>()..add(const FavoritesStarted()),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Избранное')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          return switch (state) {
            FavoritesLoaded(:final items) when items.isEmpty =>
              _EmptyFavoritesView(onOpenCatalog: () => context.go('/feed')),
            FavoritesLoaded(:final items) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _FavoriteCard(item: items[index]);
              },
            ),
            FavoritesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            FavoritesError(:final message) => _FavoritesErrorView(
              message: message,
              onRetry: () {
                context.read<FavoritesBloc>().add(const FavoritesStarted());
              },
            ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteItem item;

  const _FavoriteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _FavoriteImage(imageUrl: item.imageUrl),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            _formatPrice(item.price),
            style: const TextStyle(color: Color(0xFF666666)),
          ),
        ),
        trailing: IconButton(
          tooltip: 'Убрать из избранного',
          icon: const Icon(Icons.favorite, color: Color(0xFFF62C5B)),
          onPressed: () {
            context.read<FavoritesBloc>().add(FavoritesDeleted(id: item.id));
          },
        ),
      ),
    );
  }
}

class _FavoriteImage extends StatelessWidget {
  final String imageUrl;

  const _FavoriteImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.favorite_outline, color: Color(0xFFF62C5B)),
    );

    if (imageUrl.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  final VoidCallback onOpenCatalog;

  const _EmptyFavoritesView({required this.onOpenCatalog});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEEF3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                color: Color(0xFFF62C5B),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'В избранном пока пусто',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Сохраняйте понравившиеся позиции, чтобы быстро вернуться к ним позже.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF666666), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onOpenCatalog,
              child: const Text('Перейти в каталог'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FavoritesErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFF62C5B), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Не удалось загрузить избранное',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price.truncateToDouble() == price) {
    return '${price.toInt()} ₸';
  }

  return '${price.toStringAsFixed(2)} ₸';
}
