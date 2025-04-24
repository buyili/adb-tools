import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/device.dart';

class DeviceListNotifier extends ChangeNotifier {
  List<DeviceInfo> historyDevices = [];
  List<DeviceInfo> connectedDevices = [];
  List<DeviceInfo> allDevices = [];

  void setHistoryDevices(List<DeviceInfo> devices) {
    historyDevices = devices;
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
      var idx = tempH
          .indexWhere((device) => device.serialNumber == connedItem.serialNumber);
      if (idx == -1) continue;
      tempH.removeAt(idx);
    }
  }

  return [connectedTitle] + tempC + [previouslyTitle] + tempH;
}

final deviceListNotifierProvider = ChangeNotifierProvider<DeviceListNotifier>((ref) {
  return DeviceListNotifier();
});

final selectedDeviceProvider = StateProvider<DeviceInfo?>((ref) {
  return null;
});
