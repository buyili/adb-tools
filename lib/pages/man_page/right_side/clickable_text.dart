import 'package:adb_tools/models/command_example.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClickableText extends ConsumerWidget {
  const ClickableText(
      {super.key, this.onTap, required this.example, this.showComma = true});

  final Function()? onTap;
  final CommandExample example;
  final bool showComma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle? textStyle = const TextStyle(color: Colors.blue);
    MouseCursor mouseCursor = SystemMouseCursors.click;
    bool canClick = true;
    if (example.needDevice) {
      final sDevice = ref.watch(selectedDeviceProvider);
      if (sDevice == null) {
        textStyle = null;
        mouseCursor = MouseCursor.defer;
        canClick = false;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: canClick ? onTap : null,
          child: MouseRegion(
              cursor: mouseCursor,
              child: Text(
                example.args,
                style: textStyle,
              )),
        ),
        if (showComma) const Text(', '),
      ],
    );
  }
}
