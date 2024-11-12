import 'dart:convert';

import 'package:isar/isar.dart';

part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;
  String? ip;
  String? port;

  String get host => '$ip:$port';

  @override
  String toString() {
    return 'Device{id: $id, ip: $ip, port: $port}';
  }
}

enum DeviceState {
  offline(name: 'offline'),
  device(name: 'device'),
  noDevice(name: 'no device');

  const DeviceState({required this.name});

  final String name;
}

class DeviceInfo extends Device {
  String serialNumber = '';
  String? state;
  String? product;
  String? model;
  String? device;
  String? transportId;
  String? name;
  bool wifi = false;
  bool connected = false;

  static DeviceInfo fromDevice(Device device) {
    return DeviceInfo()
      ..id = device.id
      ..ip = device.ip
      ..port = device.port
      ..serialNumber = device.host
      ..wifi = true;
  }

  static List<DeviceInfo> merge(List<Device> devices, List<DeviceInfo> infos) {
    if (devices.isEmpty && infos.isEmpty) {
      return [];
    }
    if (devices.isEmpty) {
      return infos.map((item)=>item.clone()).toList();
    }
    var historyList = devices.map((device) => fromDevice(device)).toList();
    if (infos.isEmpty) {
      return historyList;
    }
    infos = infos.map((item)=>item.clone()).toList();
    for (var info in infos) {
      var idx =
          historyList.indexWhere((device) => device.host == info.serialNumber);
      if (idx == -1) continue;
      Device device = devices[idx];
      info
        ..id = device.id
        ..ip = device.ip
        ..port = device.port;
      historyList.removeAt(idx);
    }
    infos.addAll(historyList);
    return infos;
  }

  DeviceInfo clone(){
    return DeviceInfo()
      ..id = id
      ..ip = ip
      ..port = port
      ..serialNumber = serialNumber
      ..state = state
      ..product = product
      ..model = model
      ..device = device
      ..transportId = transportId
      ..name = name
      ..wifi = wifi
      ..connected = connected;
  }

  @override
  String toString() {
    return '${super.toString()}   DeviceInfo{serialNumber: $serialNumber, state: $state, product: $product, model: $model, device: $device, transportId: $transportId, name: $name, wifi: $wifi, connected: $connected}';
  }
}
