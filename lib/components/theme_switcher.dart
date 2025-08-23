import 'package:adb_tools/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  static const List<IconData> icons = [
    Icons.settings_brightness,
    Icons.light_mode,
    Icons.dark_mode,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(icons[themeMode.index]),
          tooltip: "Switch theme",
        );
      },
      menuChildren: ThemeMode.values
          .map((item) => MenuItemButton(
                onPressed: () => themeNotifier.toggleTheme(item),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icons[item.index]),
                    const SizedBox(width: 8),
                    Text(item.name),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
