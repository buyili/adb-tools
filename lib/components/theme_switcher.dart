import 'package:adb_tools/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    // 根据当前主题模式选择图标
    final IconData icon =
        themeMode == ThemeMode.dark ? Icons.wb_sunny : Icons.nightlight;

    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        themeNotifier.toggleTheme();
      },
      tooltip: '切换主题',
    );
  }
}
