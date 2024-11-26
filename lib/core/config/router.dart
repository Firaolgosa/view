import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:view/features/home/presentation/screens/home_screen.dart';
import 'package:view/features/web/presentation/screens/web_view_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/web-view',
      name: 'web-view',
      builder: (context, state) => const WebViewScreen(),
    ),
  ],
);