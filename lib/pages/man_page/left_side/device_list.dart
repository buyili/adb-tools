import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../components/divide_title.dart';
import '../../../utils/adb_utils.dart';
import 'device_list_tile.dart';

class DeviceList extends ConsumerStatefulWidget {
  final Function(DeviceInfo) onGetIpAndConnect;

  const DeviceList({
    super.key,
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

  // connect to device by host and port
  void _onConnect(DeviceInfo device) async {
    await ADBUtils.connect(device.serialNumber);
    refreshDeviceList(ref);
  }

  // disconnect device on TCP/IP
  void _onDisconnect(DeviceInfo device) async {
    var success = await ADBUtils.disconnect(device.serialNumber);
    if (success &&
        device.serialNumber ==
            ref.watch(selectedDeviceProvider)?.serialNumber) {
      ref.read(selectedDeviceProvider.notifier).state = null;
    }
    refreshDeviceList(ref);
  }

  // delete device from isar
  void _onDelete(Device device) {
    showDeleteDialog(
      context,
      'Delete Device',
      'Are you sure you want to delete ${device.serialNumber}?',
      () {
        final deviceListNotifier = ref.read(deviceListNotifierProvider);
        deviceListNotifier.removeHistoryDeviceById(device.serialNumber);
        Db.saveAdbDevice(deviceListNotifier.historyDevices);
      },
    );
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

          // 如果是标题，返回DevideTitle
          if (deviceItem.isTitle) {
            return DivideTitle(
              title: deviceItem.name!,
            );
          }

          // 是否被选中
          var isSelected = selectedDevice != null &&
                selectedDevice.serialNumber == deviceItem.serialNumber;
          return DeviceListTile(
            device: deviceItem,
            isSelected: isSelected,
            onTap: () {
              _onSelect(deviceItem);
            },
            onOpenTcpipPort: () {
              onOpenTcpipPort(deviceItem);
            },
            onConnect: () {
              _onConnect(deviceItem);
            },
            onDisconnect: () {
              _onDisconnect(deviceItem);
            },
            onDelete: () {
              _onDelete(deviceItem);
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

Future<dynamic> showDeleteDialog(
  BuildContext context,
  String title,
  String message,
  void Function()? onPressed,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onPressed!();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
