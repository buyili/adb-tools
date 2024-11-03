import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/cmd_plus_wrap.dart';
import 'package:cmd_plus/cmd_plus.dart';
import 'package:cross_file/cross_file.dart';

class ADBUtils {
  static final cmdPlus = CmdPlusWrap();
  static const workingDirectory = bool.fromEnvironment('dart.vm.product') ? './data/flutter_assets/assets/' : './assets/';

  static Future<CmdPlusResult> runCmd(String cmd) async {
    final result = await cmdPlus.run(cmd, [],

        /// Running in detached mode, so the process will not automatically print
        /// the output.
        mode: CmdPlusMode.detached(),
        throwOnError: false,
        workingDirectory: workingDirectory);
    return result;
  }

  static Future<List<String>> devices(OutputTextModel model) async {
    /// Run any commands
    var cmd = 'adb devices -l';
    model.updateOutput('$cmd\n');

    final result = await runCmd(cmd);

    model.updateOutput(
        '${result.error.isNotEmpty ? result.error : result.output}\n');

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
  static Future<bool> connect(OutputTextModel model, String host) async {
    var cmd = 'adb connect $host';
    model.updateOutput('$cmd\n');
    final result = await runCmd(cmd);

    model.updateOutput(
        '${result.error.isNotEmpty ? result.error : result.output}\n');

    cmdPlus.close();

    return result.output.contains('connected to');
  }

  /// disconnect from a device
  static Future<bool> disconnect(OutputTextModel model, String host) async {
    var cmd = 'adb disconnect $host';
    model.updateOutput('$cmd\n');
    final result = await runCmd(cmd);

    model.updateOutput(
        '${result.error.isNotEmpty ? result.error : result.output}\n');

    cmdPlus.close();

    return result.output.contains('disconnected ');
  }

  static Future<void> install(OutputTextModel model, Device? selectedDevice,
      List<XFile> apkFileList) async {
    if (selectedDevice == null) {
      return;
    }

    for (var apkFile in apkFileList) {
      var cmd = 'adb -s ${selectedDevice.host} install -r ${apkFile.path}';
      model.updateOutput('$cmd\n');
      final result = await runCmd(cmd);

      model.updateOutput(
          '${result.error.isNotEmpty ? result.error : result.output}\n');

      cmdPlus.close();
    }
  }
}
