import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/divide_title.dart';
import '../../utils/adb_utils.dart';
import 'device_list_tile.dart';

class DeviceList extends ConsumerStatefulWidget {
  final Function(DeviceInfo) onConnect;
  final Function(DeviceInfo) onDisconnect;
  final Function(DeviceInfo) onDelete;
  final Function(DeviceInfo) onGetIpAndConnect;

  const DeviceList({
    super.key,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    required this.onGetIpAndConnect,
  });

  @override
  ConsumerState<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends ConsumerState<DeviceList> {
  // open port for use adb over Wi-Fi
  void onOpenTcpipPort(DeviceInfo device) async {
    await ADBUtils.openTcpipPort(device.serialNumber);
  }

  void _onSelect(DeviceInfo device) {
    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice == null) {
      ref.read(selectedDeviceProvider.notifier).state = device;
      return;
    }
    ref.read(selectedDeviceProvider.notifier).state =
        selectedDevice.serialNumber == device.serialNumber ? null : device;
  }

  @override
  Widget build(BuildContext context) {
    List<DeviceInfo> devices = ref.watch(deviceListNotifierProvider).allDevices;
    DeviceInfo? selectedDevice = ref.watch(selectedDeviceProvider);

    return Expanded(
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
              _onSelect(deviceItem);
            },
            onOpenTcpipPort: () {
              onOpenTcpipPort(deviceItem);
            },
            onConnect: () {
              widget.onConnect(deviceItem);
            },
            onDisconnect: () {
              widget.onDisconnect(deviceItem);
            },
            onDelete: () {
              widget.onDelete(deviceItem);
            },
            onGetIpAndConnect: () {
              widget.onGetIpAndConnect(deviceItem);
            },
          );
        },
      ),
    );
  }
}
