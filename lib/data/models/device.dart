import 'package:isar/isar.dart';

part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;
  String? ip;
  String? port;

  String serialNumber = '';
  String? product;
  String? model;
  String? device;
  String? transportId;

  @override
  String toString() {
    return 'Device{id: $id, ip: $ip, port: $port, serialNumber: $serialNumber, product: $product, model: $model, device: $device, transportId: $transportId}';
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
  String? state;
  String? name;
  bool wifi = false;
  bool connected = false;
  bool isTitle = false;

  static DeviceInfo fromDevice(Device device) {
    return DeviceInfo()
      ..id = device.id
      ..ip = device.ip
      ..port = device.port
      ..serialNumber = device.serialNumber
      ..product = device.product
      ..model = device.model
      ..device = device.device
      ..transportId = device.transportId
      ..wifi = true;
  }

  static List<DeviceInfo> merge(List<Device> devices, List<DeviceInfo> infos) {
    if (devices.isEmpty && infos.isEmpty) {
      return [];
    }
    if (devices.isEmpty) {
      return infos.map((item) => item.clone()).toList();
    }
    var historyList = devices.map((device) => fromDevice(device)).toList();
    if (infos.isEmpty) {
      historyList.insert(0, DeviceInfo()..isTitle = true);
      return historyList;
    }
    infos = infos.map((item) => item.clone()).toList();
    for (var info in infos) {
      var idx =
          historyList.indexWhere((device) => device.serialNumber == info.serialNumber);
      if (idx == -1) continue;
      Device device = devices[idx];
      info
        ..id = device.id
        ..ip = device.ip
        ..port = device.port;
      historyList.removeAt(idx);
    }
    // add empty object to render title.
    infos.add(DeviceInfo()..isTitle = true);
    infos.addAll(historyList);
    return infos;
  }

  DeviceInfo clone() {
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
      ..connected = connected
      ..isTitle = isTitle;
  }

  @override
  String toString() {
    return '${super.toString()}'
        ' DeviceInfo{state: $state, name: $name, wifi: $wifi, connected: $connected, isTitle: $isTitle}';
  }
}
