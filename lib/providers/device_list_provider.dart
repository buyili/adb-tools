import 'package:adb_tools/db/db.dart';
import 'package:adb_tools/utils/adb_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';

class DeviceListNotifier extends ChangeNotifier {
  List<DeviceInfo> historyDevices = [];
  List<DeviceInfo> connectedDevices = [];
  List<DeviceInfo> allDevices = [];

  void setHistoryDevices(List<Device> devices) {
    if (devices.isEmpty) {
      historyDevices = [];
    } else {
      historyDevices = (devices[0] is DeviceInfo)
          ? devices as List<DeviceInfo>
          : devices.map((device) => DeviceInfo.fromDevice(device)).toList();
    }
    allDevices = merge(connectedDevices, historyDevices);
    notifyListeners();
  }

  void setConnectedDevices(List<DeviceInfo> devices) {
    connectedDevices = devices;
    allDevices = merge(connectedDevices, historyDevices);
    notifyListeners();
  }

  void addHistoryDevice(Device device) {
    device is DeviceInfo
        ? historyDevices.add(device)
        : historyDevices.add(DeviceInfo.fromDevice(device));
    allDevices = merge(connectedDevices, historyDevices);
    notifyListeners();
  }

  void removeHistoryDeviceById(String serialNumber) {
    historyDevices.removeWhere((device) => device.serialNumber == serialNumber);
    allDevices = merge(connectedDevices, historyDevices);
    notifyListeners();
  }
}

List<DeviceInfo> merge(
  List<DeviceInfo> connectedDeviceInfos,
  List<DeviceInfo> historyDeviceInfos,
) {
  var tempC = connectedDeviceInfos.map((item) => item.clone()).toList();
  var tempH = historyDeviceInfos.map((item) => item.clone()).toList();

  var connectedTitle = DeviceInfo()
    ..isTitle = true
    ..name = 'Connected devices: ${tempC.length}';
  var previouslyTitle = DeviceInfo()
    ..isTitle = true
    ..name = 'Previously connected devices: ${tempH.length}';

  if (historyDeviceInfos.isEmpty && connectedDeviceInfos.isEmpty) {
    return [connectedTitle, previouslyTitle];
  }

  if (tempC.isNotEmpty && tempH.isNotEmpty) {
    for (var connedItem in tempC) {
      var idx = tempH.indexWhere(
          (device) => device.serialNumber == connedItem.serialNumber);
      if (idx == -1) continue;
      tempH.removeAt(idx);
    }
  }

  return [connectedTitle] + tempC + [previouslyTitle] + tempH;
}

final deviceListNotifierProvider =
    ChangeNotifierProvider<DeviceListNotifier>((ref) {
  return DeviceListNotifier();
});

final selectedDeviceProvider = StateProvider<DeviceInfo?>((ref) {
  return null;
});

void refreshDeviceList(WidgetRef ref, {bool printOutput = true}) async {
  final deviceListNotifier = ref.read(deviceListNotifierProvider);
  List<DeviceInfo> tempConnectedDevices =
      await ADBUtils.devices(printOutput: printOutput);
  deviceListNotifier.setConnectedDevices(tempConnectedDevices);

  var selectedDevice = ref.read(selectedDeviceProvider);
  if (selectedDevice != null) {
    var idx = tempConnectedDevices
        .indexWhere((ele) => ele.serialNumber == selectedDevice.serialNumber);
    ref.read(selectedDeviceProvider.notifier).state =
        idx != -1 ? tempConnectedDevices[idx] : null;
  }

  _updateDbDevices(ref, tempConnectedDevices);
}

void _updateDbDevices(
    WidgetRef ref, List<DeviceInfo> tempConnectedDevices) async {
  if (tempConnectedDevices.isEmpty) return;
  var dbDevices = await Db.getSavedAdbDevice();
  bool needUpdate = false;
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
      needUpdate = true;
    } else if (onlineDevice.wifi) {
      var newDevice = Device()
        ..serialNumber = onlineDevice.serialNumber
        ..product = onlineDevice.product
        ..model = onlineDevice.model
        ..device = onlineDevice.device
        ..transportId = onlineDevice.transportId;
      dbDevices.add(newDevice);
      needUpdate = true;
    }
  }
  if (!needUpdate) return;
  Db.saveAdbDevice(dbDevices);
  ref.read(deviceListNotifierProvider).setHistoryDevices(dbDevices);
}
