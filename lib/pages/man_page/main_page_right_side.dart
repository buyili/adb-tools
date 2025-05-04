import 'package:adb_tools/pages/man_page/output_view.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/divide_title.dart';
import '../../components/my_checkbox.dart';
import '../../db/db.dart';
import '../../utils/adb_utils.dart';

class CommonCommandModel {
  String args;
  bool needDevice;
  CommonCommandModel(this.args, this.needDevice);
}

final commonCommandModels = [
  CommonCommandModel('version', false),
  CommonCommandModel('devices', false),
  CommonCommandModel('devices -l', false),
  CommonCommandModel('shell wm size', true),
  CommonCommandModel('shell getprop service.adb.tcp.port', true),
  CommonCommandModel('shell ip addr show wlan0', true),
];

/// right side widget
class RightSideWidget extends ConsumerStatefulWidget {
  final Function onShowDevices;

  const RightSideWidget({
    super.key,
    required this.onShowDevices,
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

  Future<void> _toggleExecute(String text) async {
    String command = text;
    if (command.isEmpty) {
      return;
    }
    command = command.trim();
    command = command.replaceAll(RegExp('^adb'), '');
    command = command.replaceAll('\n', '');
    var args = command.split(" ");
    args = args.where((arg) => arg.isNotEmpty).toList();

    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice != null) {
      args = ['-s', selectedDevice.serialNumber, ...args];
    }

    await ADBUtils.runCmd('adb', args);
  }

  // execute example command
  Future<void> _toggleEgCommand(CommonCommandModel commandModel) async {
    String command = commandModel.args;
    if (command.isEmpty) {
      return;
    }
    var args = command.split(" ");
    args = args.where((arg) => arg.isNotEmpty).toList();

    var selectedDevice = ref.read(selectedDeviceProvider);
    if (commandModel.needDevice && selectedDevice != null) {
      args = ['-s', selectedDevice.serialNumber, ...args];
    }

    await ADBUtils.runCmd('adb', args);
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
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Enter Command',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _textController.clear();
              },
            ),
          ),
          controller: _textController,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('eg: '),
            Expanded(
              child: Wrap(children: [
                for (final commandModel in commonCommandModels)
                  ClickableText(
                    commandModel: commandModel,
                    onTap: () {
                      _toggleEgCommand(commandModel);
                    },
                  ),
              ]),
            )
          ],
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
                    _toggleExecute(_textController.text);
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

class ClickableText extends ConsumerWidget {
  const ClickableText({super.key, this.onTap, required this.commandModel});

  final Function()? onTap;
  final CommonCommandModel commandModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle? textStyle = const TextStyle(color: Colors.blue);
    MouseCursor mouseCursor = SystemMouseCursors.click;
    if (commandModel.needDevice) {
      final sDevice = ref.watch(selectedDeviceProvider);
      if (sDevice == null) {
        textStyle = null;
        mouseCursor = MouseCursor.defer;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: MouseRegion(
              cursor: mouseCursor,
              child: Text(
                commandModel.args,
                style: textStyle,
              )),
        ),
        const Text(', '),
      ],
    );
  }
}
