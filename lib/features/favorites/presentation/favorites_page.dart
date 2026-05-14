import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malina/core/di/injection.dart';
import 'package:malina/features/favorites/bloc/favorites_bloc.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<FavoritesBloc>()..add(FavoritesStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text('Избранные')),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoaded) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text('Тут пусто', style: TextStyle(fontSize: 304)),
                );
              }

              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('${item.price} ₸'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () {
                        context.read<FavoritesBloc>().add(
                          FavoritesDeleted(id: item.id),
                        );
                      },
                    ),
                  );
                },
              );
            }
            if (state is FavoritesLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FavoritesError) {
              return Text(state.message);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
