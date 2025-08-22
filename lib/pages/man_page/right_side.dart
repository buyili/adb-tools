import 'dart:convert';

import 'package:adb_tools/pages/man_page/right_side/clickable_text.dart';
import 'package:adb_tools/pages/man_page/right_side/output_view.dart';
import 'package:adb_tools/pages/man_page/right_side/remaining_commands_tooltip.dart';
import 'package:adb_tools/pages/man_page/right_side/scrcpy_option_form.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:adb_tools/models/command_example.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/db.dart';
import '../../utils/adb_utils.dart';

/// right side widget
class RightSideWidget extends ConsumerStatefulWidget {
  const RightSideWidget({
    super.key,
  });

  @override
  ConsumerState<RightSideWidget> createState() => _RightSideWidgetState();
}

class _RightSideWidgetState extends ConsumerState<RightSideWidget> {
  final _textController = TextEditingController();
  bool turnScreenOff = false;
  List<CommandExample> commandExamples = [];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadCommandExamples();
  }

  void _loadPrefs() async {
    final savedMainConfig = await Db.getMainConfig();
    ref.read(configScreenConfig.notifier).setConfig(savedMainConfig);
  }

  void _loadCommandExamples() async {
    final jsonString =
        await rootBundle.loadString("assets/command_examples.json");
    List<CommandExample> list = (jsonDecode(jsonString) as List<dynamic>)
        .map((json) => CommandExample.fromJson(json as Map<String, dynamic>))
        .toList();
    setState(() {
      commandExamples = list;
    });
  }

  void _refreshCommands() {
    _loadCommandExamples();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing commands successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleShowDevices() async {
    refreshDeviceList(ref, printOutput: true);
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

    await ADBUtils.runCmd(args);
  }

  // execute example command
  Future<void> _toggleEgCommand(CommandExample commandModel) async {
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

    await ADBUtils.runCmd(args);
  }

  void onClear() {
    ref.read(outputTextProvider).clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScrcpyOptionForm(),
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
                // 显示前四个命令示例
                for (final commandModel in commandExamples.take(4))
                  ClickableText(
                    example: commandModel,
                    onTap: () {
                      _toggleEgCommand(commandModel);
                    },
                  ),
              ]),
            ),
            // 如果命令示例数量超过四个，显示自定义组件
            if (commandExamples.length > 4)
              RemainingCommandsTooltip(
                remainingCommands: commandExamples.skip(4).toList(),
                onTap: _toggleEgCommand,
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Theme.of(context).colorScheme.primary,
              onPressed: _refreshCommands, // 点击按钮时调用刷新方法
              tooltip:
                  'Refresh Commands List from assets/command_examples.json',
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _toggleShowDevices,
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
