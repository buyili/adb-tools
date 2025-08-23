import 'package:adb_tools/models/device.dart';
import 'package:adb_tools/providers/app_provider.dart';
import 'package:adb_tools/providers/output_text_model.dart';
import 'package:adb_tools/utils/cmd_plus_wrap.dart';
import 'package:cmd_plus/cmd_plus.dart';
import 'package:cross_file/cross_file.dart';

import '../models/cmd_task.dart';

typedef ArgsSerializeCallback = String Function(List<String> args);

class ADBUtils {
  static final cmdPlus = CmdPlusWrap();
  static const cmd = 'adb';

  static Future<CmdPlusResult> runCmd(
    List<String> args, {
    ArgsSerializeCallback? argsSerialize,
    bool printOutput = true,
  }) async {
    // get OutputTextModel instance.
    OutputTextNotifier notifier = OutputTextModelFactory.getIns();

    // serialize args
    String argsText =
        argsSerialize != null ? argsSerialize(args) : args.join(" ");
    late int taskIndex;
    if (printOutput) {
      taskIndex = notifier.addTask('$cmd $argsText');
    }

    final result = await cmdPlus.run(
      cmd,
      args,

      /// Running in detached mode, so the process will not automatically print
      /// the output.
      mode: const CmdPlusMode.detached(),
      throwOnError: false,
      workingDirectory: workDir,
    );

    if (printOutput) {
      notifier.updateTask(taskIndex,
          '${result.error.isNotEmpty ? result.error : result.output}\n');
      notifier.updateTaskStatus(taskIndex, CmdTaskStatus.success);
    }

    return result;
  }

  static Future<List<DeviceInfo>> devices({
    bool printOutput = true,
  }) async {
    /// Run any commands
    var argsText = 'devices -l';

    final result = await runCmd(argsText.split(" "), printOutput: printOutput);

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
    var argsText = 'connect $host';
    final result = await runCmd(argsText.split(" "));

    cmdPlus.close();

    return result.output.contains('connected to');
  }

  /// disconnect from a device
  static Future<bool> disconnect(String host) async {
    var argsText = 'disconnect $host';
    final result = await runCmd(argsText.split(" "));

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
      await runCmd(args, argsSerialize: (args) {
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
    DeviceInfo? selectedDevice,
    List<XFile> apkFileList,
    {String targetDir = "/sdcard/ADBTools/"}
  ) async {
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
        '$targetDir${apkFile.name}'
      ];

      await runCmd(args, argsSerialize: (args) {
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
    var argsText = '-s $serialNumber tcpip 5555';
    await runCmd(argsText.split(" "));

    cmdPlus.close();
  }

  static Future<bool> checkTcpipOpened(String serialNumber) async {
    return (await getTcpipPort(serialNumber)).isNotEmpty;
  }

  static Future<String> getTcpipPort(String serialNumber) async {
    var argsText = '-s $serialNumber shell getprop service.adb.tcp.port';
    var result = await runCmd(argsText.split(" "));

    cmdPlus.close();
    return RegExp(r'\d+').hasMatch(result.output) ? result.output.trim() : '';
  }

  static Future<String> getDeviceIp(String serialNumber) async {
    var argsText = '-s $serialNumber shell ip addr show wlan0';
    final result = await runCmd(argsText.split(" "));

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
    var argsText =
        '-s $serialNumber shell sh /sdcard/Android/data/moe.shizuku.privileged.api/start.sh';
    runCmd(argsText.split(" "));
  }

  static void startShizuku2(String serialNumber, ShizukuPackageInfo info) {
    var libDir = info.primaryCpuAbi;
    if (libDir == "arm64-v8a") {
      libDir = "arm64";
    }
    var argsText =
        '-s $serialNumber shell ${info.legacyNativeLibraryDir}/$libDir/libshizuku.so';
    runCmd(argsText.split(" "));
  }

  /// 获取Shizuku版本信息
  /// versionCode=1086 minSdk=24 targetSdk=36
  /// versionName=13.6.0.r1086.2650830c
  static Future<ShizukuPackageInfo> getShizukuPackageInfo(
      String serialNumber) async {
    var argsText =
        '-s $serialNumber shell dumpsys package moe.shizuku.privileged.api';
    var result = await runCmd(argsText.split(" "), printOutput: false);

    var vCode =
        RegExp(r'versionCode=(\d+)').firstMatch(result.output)?.group(1);
    var legacyNativeLibraryDir = RegExp(r'legacyNativeLibraryDir=(.+)')
        .firstMatch(result.output)
        ?.group(1);
    var primaryCpuAbi =
        RegExp(r'primaryCpuAbi=(.+)').firstMatch(result.output)?.group(1);
    return ShizukuPackageInfo()
      ..versionCode = vCode!
      ..legacyNativeLibraryDir = legacyNativeLibraryDir!
      ..primaryCpuAbi = primaryCpuAbi!;
  }

  /// 启动黑域
  static void startBrevent(String serialNumber) {
    var argsText =
        '-s $serialNumber shell sh /data/data/me.piebridge.brevent/brevent.sh';
    runCmd(argsText.split(" "));
  }
}

class ShizukuPackageInfo {
  late String versionCode;
  late String legacyNativeLibraryDir;
  late String primaryCpuAbi;
}
