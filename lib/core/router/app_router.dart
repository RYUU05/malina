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
          final loc = state.matchedLocation;
          int idx = 0;
          if (loc.startsWith('/favorites')) idx = 1;
          if (loc.startsWith('/add-item')) idx = 2;
          if (loc.startsWith('/profile')) idx = 3;
          if (loc.startsWith('/cart')) idx = 4;
          return MainShell(currentIndex: idx, child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const HomePage(),
          ),
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
      final onLogin = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.authenticated) {
        return onLogin ? '/feed' : null;
      }

      if (authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.lockedOut) {
        return onLogin ? null : '/login';
      }

      return null;
    },
    refreshListenable: _AuthListener(authBloc),
  );
}

final GoRouter appRouter = _createRouter(locator<AuthBloc>());

class _AuthListener extends ChangeNotifier {
  final AuthBloc _authBloc;

  _AuthListener(this._authBloc) {
    _authBloc.stream.listen((_) => notifyListeners());
  }
}
