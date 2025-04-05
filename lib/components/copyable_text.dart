import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableText extends StatelessWidget {
  final String text;

  const CopyableText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 将文本复制到剪切板
        await Clipboard.setData(ClipboardData(text: text));
        // 可选：显示一个SnackBar来通知用户文本已复制
        const snackBar = SnackBar(content: Text('文本已复制到剪切板'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
