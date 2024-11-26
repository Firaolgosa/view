import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:view/features/home/presentation/screens/home_screen.dart';
import 'package:view/features/web/presentation/screens/web_view_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/web-view',
      name: 'web-view',
      builder: (BuildContext context, GoRouterState state) {
        return const WebViewScreen();
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
);

class NavigationService {
  static void navigateTo(BuildContext context, String route, {Object? extra}) {
    context.go(route, extra: extra);
  }

  static void pushNamed(BuildContext context, String route, {Object? extra}) {
    context.pushNamed(route, extra: extra);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}
