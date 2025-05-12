import 'dart:async';

import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/pages/man_page/left_side.dart';
import 'package:adb_tools/pages/man_page/right_side.dart';
import 'package:adb_tools/providers/device_list_provider.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late DeviceListNotifier deviceListNotifier;

  @override
  void initState() {
    deviceListNotifier = ref.read(deviceListNotifierProvider);

    _init();

    // execute method after current widget build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showConnectedDevices();

      Timer.periodic(const Duration(seconds: 10), (timer) {
        showConnectedDevices(printOutput: false);
      });
    });
    super.initState();
  }

  Future<void> _init() async {
    var dbDevices = await Db.getSavedAdbDevice();
    deviceListNotifier.setHistoryDevices(dbDevices);
  }

  void _updateDbDevices(List<DeviceInfo> tempConnectedDevices) async {
    var dbDevices = await Db.getSavedAdbDevice();
    for (var onlineDevice in tempConnectedDevices) {
      var idx = dbDevices
          .indexWhere((ele) => ele.serialNumber == onlineDevice.serialNumber);

      if (idx != -1) {
        dbDevices[idx]
          ..serialNumber = onlineDevice.serialNumber
          ..product = onlineDevice.product
          ..model = onlineDevice.model
          ..device = onlineDevice.device
          ..transportId = onlineDevice.transportId;
      } else if (onlineDevice.wifi) {
        var newDevice = Device()
          ..serialNumber = onlineDevice.serialNumber
          ..product = onlineDevice.product
          ..model = onlineDevice.model
          ..device = onlineDevice.device
          ..transportId = onlineDevice.transportId;
        dbDevices.add(newDevice);
      }
    }
    Db.saveAdbDevice(dbDevices);
    deviceListNotifier.setHistoryDevices(dbDevices);
  }

  // show connected devices
  Future<void> showConnectedDevices({
    bool printOutput = true,
  }) async {
    List<DeviceInfo> tempConnectedDevices =
        await ADBUtils.devices(printOutput: printOutput);
    deviceListNotifier.setConnectedDevices(tempConnectedDevices);

    var selectedDevice = ref.read(selectedDeviceProvider);
    if (selectedDevice != null) {
      var idx = deviceListNotifier.connectedDevices
          .indexWhere((ele) => ele.serialNumber == selectedDevice.serialNumber);
      if (idx != -1) {
        ref.read(selectedDeviceProvider.notifier).state =
            deviceListNotifier.connectedDevices[idx];
      }
    }

    _updateDbDevices(tempConnectedDevices);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Flexible(
                flex: 8,
                child: LeftSide(
                  onShowDevices: showConnectedDevices,
                ),
              ),

              // right side
              Flexible(
                flex: 5,
                child: RightSideWidget(
                  onShowDevices: showConnectedDevices,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
