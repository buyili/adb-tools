import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/models/scrcpy_related/scrcpy_config.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adb_tools/components/divide_title.dart';
import 'package:adb_tools/components/my_checkbox.dart';
import 'package:flutter/material.dart';

class ScrcpyOptionForm extends ConsumerStatefulWidget {
  const ScrcpyOptionForm({super.key});

  @override
  ConsumerState<ScrcpyOptionForm> createState() => _ScrcpyOptionFormState();
}

class _ScrcpyOptionFormState extends ConsumerState<ScrcpyOptionForm> {
  @override
  Widget build(BuildContext context) {
    final mainConfig = ref.watch(configScreenConfig);
    return Column(children: [
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
    ]);
  }

  void _updateConfig(ScrcpyConfig config) {
    ref.read(configScreenConfig.notifier).setConfig(config);
    Db.saveMainConfig(config);
  }

  Future<void> _toggleTurnOffDisplay(bool? value) async {
    var config = ref.read(configScreenConfig)!;
    config = config.copyWith(
        deviceOptions: config.deviceOptions.copyWith(turnOffDisplay: value));

    _updateConfig(config);
  }

  Future<void> _toggleShowTouches(bool? value) async {
    var config = ref.read(configScreenConfig)!;
    config = config.copyWith(
        deviceOptions: config.deviceOptions.copyWith(showTouches: value));

    _updateConfig(config);
  }

  Future<void> _toggleStayAwake(bool? value) async {
    var config = ref.read(configScreenConfig)!;
    config = config.copyWith(
        deviceOptions: config.deviceOptions.copyWith(stayAwake: value));

    _updateConfig(config);
  }
}
