import 'dart:io';

import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/models/scrcpy_related/scrcpy_config.dart';

class ScrcpyRunningInstance {
  final Device device;
  final ScrcpyConfig config;
  final String scrcpyPID;
  final Process process;
  final String instanceName;
  final DateTime startTime;

  ScrcpyRunningInstance({
    required this.instanceName,
    required this.process,
    required this.device,
    required this.config,
    required this.scrcpyPID,
    required this.startTime,
  });
}
