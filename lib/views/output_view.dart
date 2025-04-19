import 'package:adb_tools/providers/cmd_task.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

TextStyle _textStyle = const TextStyle(fontSize: 12.0);

// log output view
class OutputView extends ConsumerStatefulWidget {
  const OutputView({
    super.key,
  });

  @override
  ConsumerState<OutputView> createState() => _OutputViewState();
}

class _OutputViewState extends ConsumerState<OutputView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(outputTextProvider).addListener(() {
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
      child: Consumer(
        builder: (context, ref, child) {
          OutputTextModel model = ref.watch(outputTextProvider);
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
                      Expanded(
                        child: SelectableText(
                          task.cmd,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
