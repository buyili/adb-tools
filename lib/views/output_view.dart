import 'package:adb_tools/providers/cmd_task.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

TextStyle _textStyle = const TextStyle(fontSize: 12.0);

// log output view
class OutputView extends StatefulWidget {
  const OutputView({
    super.key,
  });

  @override
  State<OutputView> createState() => _OutputViewState();
}

class _OutputViewState extends State<OutputView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<OutputTextModel>().addListener(() {
      // scroll to top when offset is not 0
      if (_scrollController.offset != 0) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Consumer<OutputTextModel>(
        builder: (context, model, child) {
          return ListView.builder(
            itemCount: model.tasks.length,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            reverse: true,
            controller: _scrollController,
            itemBuilder: (context, index) {
              CmdTask task = model.tasks[model.tasks.length - 1 - index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SelectableText(
                        task.cmd,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        task.status,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: CmdTaskStatus.getColor(task.status),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 1.0),
                  SelectableText(task.output, style: _textStyle),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
