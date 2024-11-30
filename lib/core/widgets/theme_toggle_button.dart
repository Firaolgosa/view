import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:view/core/theme/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool mini;
  
  const ThemeToggleButton({
    super.key,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: IconButton(
            key: ValueKey<bool>(themeProvider.isDarkMode),
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: mini ? 20 : 24,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          ),
        );
      },
    );
  }
}