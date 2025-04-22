import 'dart:convert';

class Device {

  String serialNumber = '';
  String? product;
  String? model;
  String? device;
  String? transportId;

  Device({
    this.serialNumber = '',
    this.product,
    this.model,
    this.device,
    this.transportId,
  });

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'product': product,
      'model': model,
      'device': device,
      'transportId': transportId,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      serialNumber: map['serialNumber']?.toString() ?? '',
      product: map['product']?.toString(),
      model: map['model']?.toString(),
      device: map['device']?.toString(),
      transportId: map['transportId']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Device.fromJson(String source) =>
      Device.fromMap(json.decode(source) as Map<String, dynamic>);

  Device copyWith({
    String? serialNumber,
    String? product,
    String? model,
    String? device,
    String? transportId,
  }) {
    return Device(
      serialNumber: serialNumber ?? this.serialNumber,
      product: product ?? this.product,
      model: model ?? this.model,
      device: device ?? this.device,
      transportId: transportId ?? this.transportId,
    );
  }

  @override
  String toString() {
    return 'Device{serialNumber: $serialNumber, product: $product, model: $model, device: $device, transportId: $transportId}';
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
  bool isHistory = false;

  static DeviceInfo fromDevice(Device device) {
    return DeviceInfo()
      ..serialNumber = device.serialNumber
      ..product = device.product
      ..model = device.model
      ..device = device.device
      ..transportId = device.transportId
      ..wifi = true
      ..isHistory = true;
  }

  DeviceInfo clone() {
    return DeviceInfo()
      ..serialNumber = serialNumber
      ..state = state
      ..product = product
      ..model = model
      ..device = device
      ..transportId = transportId
      ..name = name
      ..wifi = wifi
      ..connected = connected
      ..isTitle = isTitle
      ..isHistory = isHistory;
  }

  @override
  String toString() {
    return '${super.toString()}'
        ' DeviceInfo{state: $state, name: $name, wifi: $wifi, connected: $connected, isTitle: $isTitle}, isHistory: $isHistory}';
  }
}
