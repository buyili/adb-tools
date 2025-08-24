import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

class CopyableText extends StatelessWidget {
  final String text;

  const CopyableText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 将文本复制到剪切板
        await Clipboard.setData(ClipboardData(text: text));

        toastification.show(
          style: ToastificationStyle.simple,
          title: const Text("复制成功"),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 1),
          // ignore: use_build_context_synchronously
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor:  Theme.of(context).colorScheme.primary,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
        ),
      ),
    );
  }
}
