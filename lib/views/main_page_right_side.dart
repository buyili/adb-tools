import 'package:adb_tools/providers/output_text_model.dart';
import 'package:adb_tools/views/device_list.dart';
import 'package:adb_tools/views/output_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// right side widget
class RightSideWidget extends ConsumerStatefulWidget {
  final Function onShowDevices;
  final Function onExecute;

  const RightSideWidget({
    super.key,
    required this.onShowDevices,
    required this.onExecute,
  });

  @override
  ConsumerState<RightSideWidget> createState() => _RightSideWidgetState();
}

class _RightSideWidgetState extends ConsumerState<RightSideWidget> {
  final _textController = TextEditingController();
  bool turnScreenOff = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final turnScreenOff = prefs.getBool('turnScreenOff') ?? false;
    setState(() {
      this.turnScreenOff = turnScreenOff;
    });
  }

  void onInputArgs(String args) {
    widget.onExecute(args);
  }

  Future<void> onTurnScreenOffChanged(bool? value) async {
    setState(() {
      turnScreenOff = value!;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('turnScreenOff', value!);
  }

  void onClear() {
    ref.read(outputTextProvider).clear();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      // padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DivideTitle(title: "Scrcpy options:"),
          Row(
            children: [
              CheckboxMenuButton(
                value: turnScreenOff,
                onChanged: onTurnScreenOffChanged,
                child: const Text('Turn Screen Off'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Command',
            ),
            controller: _textController,
          ),
          Row(
            children: [
              const Text('eg: '),
              ClickableText(
                text: 'version',
                onTap: onInputArgs,
              ),
              const Text(', '),
              ClickableText(
                text: 'devices',
                onTap: onInputArgs,
              ),
              const Text(', '),
              ClickableText(
                text: 'devices -l',
                onTap: onInputArgs,
              ),
              const Text(', '),
              ClickableText(
                text: 'shell wm size',
                onTap: onInputArgs,
              ),
            ],
          ),
          // const Text(
          //   'eg: version, devices, devices -l, shell wm size',
          // ),
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
                onPressed: onClear,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          const Expanded(
            child: OutputView(),
          ),
        ],
      ),
    );
  }
}

class ClickableText extends StatelessWidget {
  const ClickableText({super.key, required this.text, this.onTap});

  final String text;
  final Function(String)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(text);
        }
      },
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            text,
            style: const TextStyle(color: Colors.blue),
          )),
    );
  }
}
