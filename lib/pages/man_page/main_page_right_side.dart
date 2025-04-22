import 'package:adb_tools/pages/man_page/output_view.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/divide_title.dart';
import '../../components/my_checkbox.dart';
import '../../db/db.dart';

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
    final savedMainConfig = await Db.getMainConfig();
    ref.read(configScreenConfig.notifier).setConfig(savedMainConfig);
  }

  void onInputArgs(String args) {
    widget.onExecute(args);
  }

  Future<void> _toggleTurnOffDisplay(bool? value) async {
    final config = ref.read(configScreenConfig)!;
    final turnOffDisplay = config.deviceOptions.turnOffDisplay;

    ref
        .read(configScreenConfig.notifier)
        .setDeviceConfig(turnOffDisplay: !turnOffDisplay);
    Db.saveMainConfig(ref.read(configScreenConfig)!);
  }

  Future<void> _toggleShowTouches(bool? value) async {
    final config = ref.read(configScreenConfig)!;
    final showTouches = config.deviceOptions.showTouches;

    ref
        .read(configScreenConfig.notifier)
        .setDeviceConfig(showTouches: !showTouches);
    Db.saveMainConfig(ref.read(configScreenConfig)!);
  }

  Future<void> _toggleStayAwake(bool? value) async {
    final config = ref.read(configScreenConfig)!;
    final stayAwake = config.deviceOptions.stayAwake;

    ref
        .read(configScreenConfig.notifier)
        .setDeviceConfig(stayAwake: !stayAwake);
    Db.saveMainConfig(ref.read(configScreenConfig)!);
  }

  void onClear() {
    ref.read(outputTextProvider).clear();
  }

  @override
  Widget build(BuildContext context) {
    final mainConfig = ref.watch(configScreenConfig);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DivideTitle(title: "Scrcpy options:"),
        Wrap(
          direction: Axis.horizontal,
          spacing: 12.0,
          children: [
            MyCheckbox(
              value: mainConfig?.deviceOptions.turnOffDisplay ?? false,
              onChanged: _toggleTurnOffDisplay,
              child: const Text('Turn Screen Off'),
            ),
            MyCheckbox(
              value: mainConfig?.deviceOptions.showTouches ?? false,
              onChanged: _toggleShowTouches,
              child: const Text('Show Touches'),
            ),
            MyCheckbox(
              value: mainConfig?.deviceOptions.stayAwake ?? false,
              onChanged: _toggleStayAwake,
              child: const Text('Stay Awake'),
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
