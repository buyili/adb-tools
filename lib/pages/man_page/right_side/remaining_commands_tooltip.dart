import 'package:adb_tools/models/command_example.dart';
import 'package:adb_tools/pages/man_page/right_side/clickable_text.dart';
import 'package:flutter/material.dart';

class RemainingCommandsTooltip extends StatelessWidget {
  final List<CommandExample> remainingCommands;
  final Function(CommandExample) onTap;

  const RemainingCommandsTooltip({
    super.key,
    required this.remainingCommands,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenHeight * 0.5, // 设置最大高度为屏幕高度的50%
                ),
                child: SingleChildScrollView(
                  child: ListBody(
                    children: remainingCommands.map((commandModel) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 8.0),
                        child: ClickableText(
                          example: commandModel,
                          onTap: () {
                            onTap(commandModel);
                            Navigator.of(context).pop();
                          },
                          showComma: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // 关闭弹窗
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
      icon: Icon(
        Icons.more_horiz,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
