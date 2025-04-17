import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/cmd_plus_wrap.dart';
import 'package:cmd_plus/cmd_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../models/cmd_task.dart';

typedef ArgsSerializeCallback = String Function(List<String> args);

class ADBUtils {
  static final cmdPlus = CmdPlusWrap();
  static const workingDirectory = bool.fromEnvironment('dart.vm.product')
      ? './data/flutter_assets/assets/adb-win'
      : './assets/adb-win';

  static Future<CmdPlusResult> runCmd(
    String cmd,
    List<String> args, {
    ArgsSerializeCallback? argsSerialize,
  }) async {
    // get OutputTextModel instance.
    OutputTextModel model = OutputTextModelFactory.getIns();

    // serialize args
    String argsText =
        argsSerialize != null ? argsSerialize(args) : args.join(" ");
    int taskIndex = model.addTask('$cmd $argsText');

    final result = await cmdPlus.run(
      cmd,
      args,

      /// Running in detached mode, so the process will not automatically print
      /// the output.
      mode: const CmdPlusMode.detached(),
      throwOnError: false,
      workingDirectory: workingDirectory,
    );

    model.updateTask(taskIndex,
        '${result.error.isNotEmpty ? result.error : result.output}\n');
    model.updateTaskStatus(taskIndex, CmdTaskStatus.success);

    return result;
  }

  static Future<List<DeviceInfo>> devices() async {
    /// Run any commands
    var cmd = 'adb devices -l';

    final result = await runCmd(cmd, []);

    List<DeviceInfo> devices = [];
    if (result.error.isEmpty) {
      /// Extract the host names from the output.
      var pattern = RegExp(
          r'\n(.+)\b +(offline|device|no device) product:(.+) model:(.+) device:(.+) transport_id:(.+)');
      var matches = pattern.allMatches(result.output);
      for (var match in matches) {
        var serialNumber = match.group(1).toString();
        var state = match.group(2).toString();
        var deviceInfo = DeviceInfo()
          ..serialNumber = serialNumber
          ..state = state
          ..product = match.group(3).toString()
          ..model = match.group(4).toString()
          ..device = match.group(5).toString()
          ..transportId = match.group(6).toString()
          ..wifi = serialNumber.contains(":")
          ..connected = state == DeviceState.device.name;
        devices.add(deviceInfo);
      }
    }

    cmdPlus.close();

    return devices;
  }

  // connect to a device
  static Future<bool> connect(String host) async {
    var cmd = 'adb connect $host';
    final result = await runCmd(cmd, []);

    cmdPlus.close();

    return result.output.contains('connected to');
  }

  /// disconnect from a device
  static Future<bool> disconnect(String host) async {
    var cmd = 'adb disconnect $host';
    final result = await runCmd(cmd, []);

    cmdPlus.close();

    return result.output.contains('disconnected ');
  }

  static Future<void> install(
      DeviceInfo? selectedDevice, List<XFile> apkFileList) async {
    if (selectedDevice == null) {
      return;
    }

    for (var apkFile in apkFileList) {
      var args = [
        '-s',
        selectedDevice.serialNumber,
        'install',
        '-r',
        apkFile.path
      ];
      await runCmd('adb', args, argsSerialize: (args) {
        return args
            .asMap()
            .entries
            .map((entry) {
              if (args.length - entry.key <= 1) {
                return '"${entry.value}"';
              }
              return entry.value;
            })
            .toList()
            .join(" ");
      });

      cmdPlus.close();
    }
  }

  static Future<void> push(
      DeviceInfo? selectedDevice, List<XFile> apkFileList) async {
    if (selectedDevice == null) {
      return;
    }

    for (var apkFile in apkFileList) {
      var args = [
        '-s',
        selectedDevice.serialNumber,
        'push',
        '--sync',
        apkFile.path,
        '/sdcard/${apkFile.name}'
      ];

      await runCmd('adb', args, argsSerialize: (args) {
        return args
            .asMap()
            .entries
            .map((entry) {
              if (args.length - entry.key <= 2) {
                return '"${entry.value}"';
              }
              return entry.value;
            })
            .toList()
            .join(" ");
      });
    }
    cmdPlus.close();
  }

  static openTcpipPort(String serialNumber) async {
    var cmd = 'adb -s $serialNumber tcpip 5555';
    await runCmd(cmd, []);

    cmdPlus.close();
  }

  static Future<bool> checkTcpipOpened(String serialNumber) async {
    var cmd = 'adb -s $serialNumber shell getprop service.adb.tcp.port';
    var result = await runCmd(cmd, []);

    cmdPlus.close();
    return RegExp(r'\d+').hasMatch(result.output);
  }

  static Future<String> getDeviceIp(String serialNumber) async {
    var cmd = 'adb -s $serialNumber shell ip addr show wlan0';
    final result = await runCmd(cmd, []);

    if (result.error.isNotEmpty) {
      return "";
    }

    return getIp(result.output);
  }

  static String getIp(String text) {
    var pattern = RegExp(r'inet\s(\d+?\.\d+?\.\d+?\.\d+?)/\d+');
    var allMatches = pattern.allMatches(text);
    if (allMatches.isNotEmpty) {
      return allMatches.first.group(1).toString();
    }
    return "";
  }

  static void startShizuku(String serialNumber) {
    var cmd = 'adb -s $serialNumber shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh';
    runCmd(cmd, []);
  }
}
