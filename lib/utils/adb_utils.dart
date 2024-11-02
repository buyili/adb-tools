import 'package:adb_tools/data/models/device.dart';
import 'package:adb_tools/models/output_text_model.dart';
import 'package:adb_tools/utils/cmd_plus_wrap.dart';
import 'package:cmd_plus/cmd_plus.dart';
import 'package:cross_file/cross_file.dart';

class ADBUtils {
  static final cmdPlus = CmdPlusWrap();

  static Future<CmdPlusResult> runCmd(String cmd) async {
    final result = await cmdPlus.run(
      cmd,
      [],

      /// Running in detached mode, so the process will not automatically print
      /// the output.
      mode: CmdPlusMode.detached(),
      throwOnError: false,
    );
    return result;
  }

  static Future<List<String>> devices(OutputTextModel model) async {
    /// Run any commands
    var cmd = 'adb devices -l';
    model.updateOutput('$cmd\n');

    final result = await runCmd(cmd);

    /// Print the output of the process.
    // cmdPlus.logger.write(result.output);

    model.updateOutput(result.output);

    /// Extract the host names from the output.
    var pattern = RegExp(r'\n(.+)	(.+)');
    var matches = pattern.allMatches(result.output);
    var hosts = <String>[];
    for (var match in matches) {
      hosts.add(match.group(1).toString());
    }
    // debugPrint(hosts.toString());

    cmdPlus.close();

    return hosts;
  }

  // connect to a device
  static Future<bool> connect(OutputTextModel model, String host) async {
    var cmd = 'adb connect $host';
    model.updateOutput('$cmd\n');
    final result = await runCmd(cmd);

    model.updateOutput('${result.output}\n');

    cmdPlus.close();

    return result.output.contains('connected to');
  }

  /// disconnect from a device
  static Future<bool> disconnect(OutputTextModel model, String host) async {
    var cmd = 'adb disconnect $host';
    model.updateOutput('$cmd\n');
    final result = await runCmd(cmd);

    if (result.error.isNotEmpty) {
      model.updateOutput('${result.error}\n');
      cmdPlus.close();
      return false;
    }

    model.updateOutput('${result.output}\n');

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
