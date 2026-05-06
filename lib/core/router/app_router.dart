import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/cart/presentation/add_item_page.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/home/presentation/favorites_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/shell/main_shell.dart';
import '../di/injection.dart';

GoRouter _createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/add-item',
        builder: (context, state) => const AddItemPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          int index = 0;
          if (location.startsWith('/favorites')) {
            index = 1;
          } else if (location.startsWith('/add-item')) {
            index = 2;
          } else if (location.startsWith('/profile')) {
            index = 3;
          } else if (location.startsWith('/cart')) {
            index = 4;
          }
          return MainShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(path: '/feed', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/cart',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return CartPage(categoryFilter: category);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoginRoute = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.authenticated) {
        // Redirect to feed if trying to access login
        if (isLoginRoute) return '/feed';
        return null;
      }

      if (authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.lockedOut) {
        return isLoginRoute ? null : '/login';
      }

      return null;
    },
    refreshListenable: _AuthBlocListenable(authBloc),
  );
}

final GoRouter appRouter = _createRouter(locator<AuthBloc>());

class _AuthBlocListenable extends ChangeNotifier {
  final AuthBloc _authBloc;

  _AuthBlocListenable(this._authBloc) {
    _authBloc.stream.listen((_) => notifyListeners());
  }
}
