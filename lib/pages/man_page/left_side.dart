import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adb_tools/pages/man_page/left_side/top_form.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:flutter/material.dart';
import 'package:adb_tools/pages/man_page/apk_drop_target.dart';
import 'package:adb_tools/pages/man_page/device_list.dart';

class LeftSide extends ConsumerStatefulWidget {
  const LeftSide({super.key});

  @override
  ConsumerState<LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends ConsumerState<LeftSide> {
  Future<void> showConnectedDevices() async {
    refreshDeviceList(ref, printOutput: false);
  }

  // connect to device and save ip address and port to isar
  void onConnectInputIPAddress(String ip, String port) async {
    // connect to device
    bool connected = await ADBUtils.connect('$ip:$port');
    showConnectedDevices();
    if (!connected) {
      debugPrint("connection failed");
      return;
    }

    onSaveDeviceIPAddressToDB(ip, port, showExistsSnackBar: false);
  }

  // save ip address and port to isar
  void onSaveDeviceIPAddressToDB(String ip, String port,
      {bool showExistsSnackBar = true}) async {
    // save ip address and port to isar
    var serialNumber = '$ip:$port';
    bool exists = ref
        .read(deviceListNotifierProvider)
        .historyDevices
        .any((device) => device.serialNumber == serialNumber);
    if (exists) {
      if (showExistsSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$serialNumber already exists.')),
        );
      }
    } else {
      var newDevice = Device()..serialNumber = serialNumber;
      var deviceListNotifier = ref.read(deviceListNotifierProvider);
      deviceListNotifier.addHistoryDevice(newDevice);
      Db.saveAdbDevice(deviceListNotifier.historyDevices);
    }
  }

  void onSelect(DeviceInfo device) {
    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice == null) {
      ref.read(selectedDeviceProvider.notifier).state = device;
      return;
    }
    ref.read(selectedDeviceProvider.notifier).state =
        selectedDevice.serialNumber == device.serialNumber ? null : device;
  }

  // open port for use adb over Wi-Fi
  void onOpenTcpipPort(DeviceInfo device) async {
    await ADBUtils.openTcpipPort(device.serialNumber);
  }

  // connect to device by host and port
  void onConnect(DeviceInfo device) async {
    await ADBUtils.connect(device.serialNumber);
    await showConnectedDevices();
  }

  // get device ip and connect
  void onGetIpAndConnect(DeviceInfo device) async {
    // check tcpip opened
    var tcpipOpened = await ADBUtils.checkTcpipOpened(device.serialNumber);
    if (!tcpipOpened) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please open tcpip port first.')),
        );
      }
      return;
    }

    // get device ip
    var ip = await ADBUtils.getDeviceIp(device.serialNumber);
    if (ip.isEmpty) {
      // show snackbar if ip is empty
      var snackBar = SnackBar(
        content: Text('Not found device ip for [${device.serialNumber}].'),
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            // Some code to undo the change.
            ScaffoldMessenger.of(context).clearSnackBars();
          },
        ),
      );

      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    await ADBUtils.connect(ip);
    onSaveDeviceIPAddressToDB(ip, "5555", showExistsSnackBar: false);
    await showConnectedDevices();
  }

  // disconnect device on TCP/IP
  void onDisconnect(DeviceInfo device) async {
    var success = await ADBUtils.disconnect(device.serialNumber);
    if (success && device == ref.watch(selectedDeviceProvider)) {
      ref.read(selectedDeviceProvider.notifier).state = null;
    }
    await showConnectedDevices();
  }

  // delete device from isar
  void onDelete(Device device) {
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
    return Column(
      children: [
        // text input
        TopForm(
          onSubmit: onConnectInputIPAddress,
          onSave: onSaveDeviceIPAddressToDB,
        ),

        const SizedBox(height: 10.0),
        const Divider(
          height: 1,
        ),

        // device list
        DeviceList(
          onSelect: onSelect,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
          onDelete: onDelete,
          onGetIpAndConnect: onGetIpAndConnect,
        ),

        const SizedBox(height: 10.0),

        const ApkDragTarget(),
      ],
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
