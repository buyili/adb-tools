import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/providers/device_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/divide_title.dart';
import '../../utils/adb_utils.dart';
import 'device_list_tile.dart';

class DeviceList extends ConsumerWidget {
  final Function(DeviceInfo) onSelect;
  final Function(DeviceInfo) onConnect;
  final Function(DeviceInfo) onDisconnect;
  final Function(DeviceInfo) onDelete;
  final Function(DeviceInfo) onGetIpAndConnect;

  const DeviceList({
    super.key,
    required this.onSelect,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    required this.onGetIpAndConnect,
  });

  // open port for use adb over Wi-Fi
  void onOpenTcpipPort(DeviceInfo device) async {
    await ADBUtils.openTcpipPort(device.serialNumber);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DeviceInfo> devices = ref.watch(deviceListProvider).allDevices;
    DeviceInfo? selectedDevice = ref.watch(selectedDeviceProvider);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            var deviceItem = devices[index];
            if (deviceItem.isTitle) {
              return DivideTitle(
                title: deviceItem.name!,
              );
            }
            return DeviceListTile(
              device: deviceItem,
              isSelected: selectedDevice != null &&
                  selectedDevice.serialNumber == deviceItem.serialNumber,
              onTap: () {
                onSelect(deviceItem);
              },
              onOpenTcpipPort: () {
                onOpenTcpipPort(deviceItem);
              },
              onConnect: () {
                onConnect(deviceItem);
              },
              onDisconnect: () {
                onDisconnect(deviceItem);
              },
              onDelete: () {
                onDelete(deviceItem);
              },
              onGetIpAndConnect: () {
                onGetIpAndConnect(deviceItem);
              },
            );
          },
        ),
      ),
    );
  }
}
