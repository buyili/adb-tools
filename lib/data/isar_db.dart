import 'package:adb_tools/data/models/device.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDb {
  static late Isar _isar;

  static Future<void> initInstance() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [DeviceSchema],
      directory: dir.path,
    );
    _isar = isar;
  }

  static Isar getIns() {
    return _isar;
  }
}
