import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:view/core/theme/theme_provider.dart';
import 'package:view/core/config/router.dart';
import 'dart:developer';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Your App',
          routerConfig: router,
          theme: themeProvider.currentTheme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
