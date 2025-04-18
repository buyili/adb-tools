import 'package:isar/isar.dart';

part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;

  String serialNumber = '';
  String? product;
  String? model;
  String? device;
  String? transportId;

  @override
  String toString() {
    return 'Device{id: $id, serialNumber: $serialNumber, product: $product, model: $model, device: $device, transportId: $transportId}';
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
      ..serialNumber = device.serialNumber
      ..product = device.product
      ..model = device.model
      ..device = device.device
      ..transportId = device.transportId
      ..wifi = true;
  }

  DeviceInfo clone() {
    return DeviceInfo()
      ..id = id
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
