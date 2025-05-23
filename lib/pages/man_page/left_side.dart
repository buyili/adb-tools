import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/pages/man_page/left_side/apk_drop_target.dart';
import 'package:adb_tools/pages/man_page/left_side/device_list.dart';
import 'package:adb_tools/pages/man_page/left_side/top_form.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeftSide extends ConsumerStatefulWidget {
  const LeftSide({super.key});

  @override
  ConsumerState<LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends ConsumerState<LeftSide> {
  Future<void> showConnectedDevices() async {
    refreshDeviceList(ref);
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

  // open port for use adb over Wi-Fi
  void onOpenTcpipPort(DeviceInfo device) async {
    await ADBUtils.openTcpipPort(device.serialNumber);
  }

  // get device ip and connect
  void onGetIpAndConnect(DeviceInfo device) async {
    // check tcpip opened
    var tcpipPort = await ADBUtils.getTcpipPort(device.serialNumber);
    if (tcpipPort.isEmpty) {
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
    onSaveDeviceIPAddressToDB(ip, tcpipPort, showExistsSnackBar: false);
    await showConnectedDevices();
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
          onGetIpAndConnect: onGetIpAndConnect,
        ),

        const SizedBox(height: 10.0),

        const ApkDragTarget(),
      ],
    );
  }
}
