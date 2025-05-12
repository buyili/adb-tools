import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/models/scrcpy_related/scrcpy_config.dart';
import 'package:adb_tools/providers/config_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adb_tools/components/divide_title.dart';
import 'package:adb_tools/components/my_checkbox.dart';
import 'package:flutter/material.dart';

class _DropdownItem {
  final int value;
  final String label;

  _DropdownItem({required this.value, required this.label});
}

final _dropdownItems = [1, 5, 8, 10, 20, 30, 40, 50, 80, 100]
    .map((bitrate) => _DropdownItem(value: bitrate, label: '${bitrate}Mbps'))
    .toList();

class ScrcpyOptionForm extends ConsumerStatefulWidget {
  const ScrcpyOptionForm({super.key});

  @override
  ConsumerState<ScrcpyOptionForm> createState() => _ScrcpyOptionFormState();
}

class _ScrcpyOptionFormState extends ConsumerState<ScrcpyOptionForm> {
  @override
  Widget build(BuildContext context) {
    final mainConfig = ref.watch(configScreenConfig);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Scrcpy options:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            MySelect(
                options: _dropdownItems,
                value: mainConfig?.videoOptions.videoBitrate ?? 8,
                label: 'Bit Rate',
                onChanged: _selectBitrate),
            Expanded(
              child: Wrap(
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
            ),
          ],
        ),
      ],
    );
  }

  void _updateConfig(ScrcpyConfig config) {
    ref.read(configScreenConfig.notifier).setConfig(config);
    Db.saveMainConfig(config);
  }

  Future<void> _selectBitrate(int? value) async {
    var config = ref.read(configScreenConfig)!;
    config = config.copyWith(
        videoOptions: config.videoOptions.copyWith(videoBitrate: value));

    _updateConfig(config);
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

class MySelect extends StatelessWidget {
  const MySelect({
    super.key,
    required this.value,
    required this.options,
    required this.label,
    required this.onChanged,
  });
  final List<_DropdownItem> options;
  final int value;
  final String label;
  final Function(int?) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<int>(
        value: value,
        items: options.map((_DropdownItem option) {
          return DropdownMenuItem<int>(
            value: option.value,
            child: Text(option.label),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
