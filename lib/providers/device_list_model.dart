import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/device.dart';

class DeviceListModel extends ChangeNotifier {
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

  void removeHistoryDeviceById(int id) {
    historyDevices.removeWhere((device) => device.id == id);
    allDevices = merge(connectedDevices, historyDevices);
    notifyListeners();
  }
}

List<DeviceInfo> merge(
  List<DeviceInfo> connectedDeviceInfos,
  List<DeviceInfo> historyDeviceInfos,
) {
  if (historyDeviceInfos.isEmpty && connectedDeviceInfos.isEmpty) {
    return [];
  }

  var tempC = connectedDeviceInfos.map((item) => item.clone()).toList();
  var tempH = historyDeviceInfos.map((item) => item.clone()).toList();
  if (tempC.isNotEmpty && tempH.isNotEmpty) {
    for (var info in tempC) {
      var idx = tempH
          .indexWhere((device) => device.serialNumber == info.serialNumber);
      if (idx == -1) continue;
      Device device = tempH[idx];
      info.id = device.id;
      tempH.removeAt(idx);
    }
  }
  return [
        DeviceInfo()
          ..isTitle = true
          ..name = 'Connected devices: ${tempC.length}'
      ] +
      tempC +
      [
        DeviceInfo()
          ..isTitle = true
          ..name = 'Previously connected devices: ${tempH.length}'
      ] +
      tempH;
}

final deviceListProvider = ChangeNotifierProvider<DeviceListModel>((ref){
  return DeviceListModel();
});

final selectedDeviceProvider = StateProvider<DeviceInfo?>((ref){
  return null;
});