import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection_container.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/signup_page.dart';
import '../../features/meal_tracking/presentation/bloc/meal_bloc.dart';
import '../../features/meal_tracking/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      refreshListenable: _AuthBlocListenable(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuth = authState is AuthAuthenticated;
        final isOnAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (!isAuth && !isOnAuth) return '/login';
        if (isAuth && isOnAuth) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider.value(
            value: authBloc,
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => BlocProvider.value(
            value: authBloc,
            child: const SignupPage(),
          ),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: authBloc),
              BlocProvider(create: (_) => sl<MealBloc>()),
            ],
            child: const DashboardPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => BlocProvider.value(
            value: authBloc,
            child: const SettingsPage(),
          ),
        ),
        GoRoute(
          path: '/',
          redirect: (_, __) => '/dashboard',
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page introuvable: ${state.error}'),
        ),
      ),
    );
  }
}

class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
