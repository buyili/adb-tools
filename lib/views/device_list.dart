import 'package:adb_tools/data/models/device.dart';
import 'package:flutter/material.dart';

import 'device_list_tile.dart';

class DeviceList extends StatelessWidget {
  final List<DeviceInfo> devices;
  final DeviceInfo? selectedDevice;
  final Function(DeviceInfo) onOpenPort;
  final Function(DeviceInfo) onSelect;
  final Function(DeviceInfo) onConnect;
  final Function(DeviceInfo) onDisconnect;
  final Function(DeviceInfo) onDelete;

  const DeviceList({
    super.key,
    required this.devices,
    required this.selectedDevice,
    required this.onOpenPort,
    required this.onSelect,
    required this.onConnect,
    required this.onDisconnect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            if(devices[index].isTitle){
              return const DivideTitle();
            }
            return DeviceListTile(
              device: devices[index],
              isSelected: selectedDevice == devices[index],
              onTap: () {
                onSelect(devices[index]);
              },
              onOpenPort: (){
                onOpenPort(devices[index]);
              },
              onConnect: () {
                onConnect(devices[index]);
              },
              onDisconnect: () {
                onDisconnect(devices[index]);
              },
              onDelete: () {
                onDelete(devices[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class DivideTitle extends StatelessWidget {
  const DivideTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16, top: 18, right: 8, bottom: 0),
      child: Text('Previously connected devices'),
    );
  }
}

