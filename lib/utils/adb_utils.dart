import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/cmd_plus_wrap.dart';
import 'package:cmd_plus/cmd_plus.dart';
import 'package:cross_file/cross_file.dart';

typedef ArgsSerializeCallback = String Function(List<String> args);

class ADBUtils {
  static final cmdPlus = CmdPlusWrap();
  static const workingDirectory = bool.fromEnvironment('dart.vm.product')
      ? './data/flutter_assets/assets/'
      : './assets/';

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
      mode: CmdPlusMode.detached(),
      throwOnError: false,
      workingDirectory: workingDirectory,
    );

    model.updateTask(taskIndex,
        '${result.error.isNotEmpty ? result.error : result.output}\n');

    return result;
  }

  static Future<List<String>> devices() async {
    /// Run any commands
    var cmd = 'adb devices -l';

    final result = await runCmd(cmd, []);

    var hosts = <String>[];
    if (result.error.isEmpty) {
      /// Extract the host names from the output.
      var pattern = RegExp(r'\n(.+)	(.+)');
      var matches = pattern.allMatches(result.output);
      for (var match in matches) {
        hosts.add(match.group(1).toString());
      }
    }

    cmdPlus.close();

    return hosts;
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
      Device? selectedDevice, List<XFile> apkFileList) async {
    if (selectedDevice == null) {
      return;
    }

    for (var apkFile in apkFileList) {
      var args = ['-s', selectedDevice.host, 'install', '-r', apkFile.path];
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
      Device? selectedDevice, List<XFile> apkFileList) async {
    if (selectedDevice == null) {
      return;
    }

    for (var apkFile in apkFileList) {
      var args = [
        '-s',
        selectedDevice.host,
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
}
