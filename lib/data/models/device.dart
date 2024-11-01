import 'package:isar/isar.dart';
part 'device.g.dart';

@collection
class Device {
  Id id = Isar.autoIncrement;
  String? ip;
  String? port;
}
