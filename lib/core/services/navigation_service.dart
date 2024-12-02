import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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