
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/views/output_view.dart';
import 'package:flutter/material.dart';


/// right side widget
class RightSideWidget extends StatefulWidget {
  final OutputTextModel model;
  final ScrollController _scrollController;
  final Function onShowDevices;
  final Function onExecute;

  const RightSideWidget({
    super.key,
    required this.model,
    required ScrollController scrollController,
    required this.onShowDevices,
    required this.onExecute,
  }) : _scrollController = scrollController;

  @override
  State<RightSideWidget> createState() => _RightSideWidgetState();
}

class _RightSideWidgetState extends State<RightSideWidget> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      // padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Command',
            ),
            controller: _textController,
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.onShowDevices();
                    },
                    child: const Text('Show Devices'),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      widget.onExecute(_textController.text);
                    },
                    child: const Text('Execute'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  widget.model.clear();
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: OutputView(scrollController: widget._scrollController),
          ),
        ],
      ),
    );
  }
}