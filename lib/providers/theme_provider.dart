import 'package:adb_tools/db/db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 定义主题状态管理
final themeProvider = StateNotifierProvider<ThemeProvider, ThemeMode>((ref) {
  return ThemeProvider();
});

class ThemeProvider extends StateNotifier<ThemeMode> {
  ThemeProvider() : super(ThemeMode.system);

  ThemeProvider.from(super._state);

  // 切换主题的方法
  void toggleTheme(ThemeMode theme) {
    state = theme;
    Db.saveTheme(theme);
  }
}
