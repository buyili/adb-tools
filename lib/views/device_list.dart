import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/providers/device_list_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'device_list_tile.dart';

class DeviceList extends StatelessWidget {
  final DeviceInfo? selectedDevice;
  final Function(DeviceInfo) onOpenTcpipPort;
  final Function(DeviceInfo) onSelect;
  final Function(DeviceInfo) onConnect;
  final Function(DeviceInfo) onDisconnect;
  final Function(DeviceInfo) onDelete;
  final Function(DeviceInfo) onGetIpAndConnect;

  const DeviceList({
    super.key,
    required this.selectedDevice,
    required this.onOpenTcpipPort,
    required this.onSelect,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
    required this.onGetIpAndConnect,
  });

  @override
  Widget build(BuildContext context) {
    List<DeviceInfo> devices = context.watch<DeviceListModel>().allDevices;
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
                  selectedDevice!.serialNumber == deviceItem.serialNumber,
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

class DivideTitle extends StatelessWidget {
  const DivideTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, right: 8, bottom: 0),
      child: Text(title),
    );
  }
}
